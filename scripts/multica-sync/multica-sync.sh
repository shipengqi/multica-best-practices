#!/bin/bash
# multica-sync.sh — 统一 Multica 工作区同步脚本 / Unified Multica workspace sync script
# 用 Multica CLI 实现 init, sync, clone, list, export 子命令
# Uses official Multica CLI for squad and skill management

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${MULTICA_CONFIG_FILE:-config.local.json}"
DRY_RUN=${MULTICA_DRY_RUN:-false}

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check dependencies
check_deps() {
    if ! command -v multica &> /dev/null; then
        echo -e "${RED}❌ multica CLI not found${NC}"
        echo "   Install: npm install -g multica"
        echo "   Docs: https://multica.ai/docs/zh/cli"
        exit 1
    fi
}

# Load config and set workspace
load_config() {
    local workspace=""

    if [[ -f "$CONFIG_FILE" ]]; then
        workspace=$(grep -o '"workspace"[^"]*"[^"]*"' "$CONFIG_FILE" | tail -1 | cut -d'"' -f4)
        if [[ -n "$workspace" ]]; then
            export MULTICA_WORKSPACE_ID="$workspace"
            multica config set workspace_id "$workspace" > /dev/null 2>&1 || true
        fi
    fi

    if [[ -z "${MULTICA_WORKSPACE_ID:-}" ]]; then
        echo -e "${RED}❌ Workspace not configured${NC}"
        echo "   Set MULTICA_WORKSPACE_ID env var or workspace in $CONFIG_FILE"
        exit 1
    fi
}

# List squads
cmd_list() {
    local workspace="${1:-}"
    [[ -z "$workspace" ]] && workspace="$MULTICA_WORKSPACE_ID"

    echo -e "${BLUE}📋 Squads in workspace '$workspace':${NC}"
    multica squad list --workspace-id "$workspace" --output json 2>/dev/null | \
        jq -r '.[] | "\(.name) (\(.id))"' || \
        multica squad list --workspace-id "$workspace"
}

# Export entire workspace to JSON
cmd_export() {
    echo -e "${BLUE}📤 Exporting entire workspace '$MULTICA_WORKSPACE_ID'...${NC}"

    # Get all agents
    local agents=$(multica agent list --output json 2>/dev/null || echo "[]")

    # Get all squads
    local squads=$(multica squad list --workspace-id "$MULTICA_WORKSPACE_ID" --output json 2>/dev/null || echo "[]")

    # Get all skills
    local skills=$(multica skill list --output json 2>/dev/null || echo "[]")

    # Build enriched agents with their squad and skill bindings
    local enriched_agents=$(echo "$agents" | jq -c '.[] | {
        id: .id,
        name: .name,
        squads: [],
        skills: []
    }')

    # For each squad, add members to agents
    local squads_data=$(echo "$squads" | jq -c '.[]')

    while IFS= read -r squad_line; do
        [[ -z "$squad_line" ]] && continue

        local squad_id=$(echo "$squad_line" | jq -r '.id')
        local squad_name=$(echo "$squad_line" | jq -r '.name')

        # Get squad members
        local members=$(multica squad member list "$squad_id" --output json 2>/dev/null || echo "[]")

        # For each member, track which squad they belong to
        echo "$members" | jq -c '.[] | select(.agent_id != null) | .agent_id' | while read -r agent_id; do
            [[ -z "$agent_id" ]] && continue
            # Will be merged later
        done
    done <<< "$squads_data"

    # Build the export with all relationships
    local export_data=$(jq -n \
        --arg ws "$MULTICA_WORKSPACE_ID" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        --argjson agents_list "$agents" \
        --argjson squads_list "$squads" \
        --argjson skills_list "$skills" \
        '{
            workspace_id: $ws,
            exported_at: $ts,
            summary: {
                agents_count: ($agents_list | length),
                squads_count: ($squads_list | length),
                skills_count: ($skills_list | length)
            },
            agents: $agents_list,
            squads: $squads_list,
            skills: $skills_list,
            agent_squad_bindings: [],
            agent_skill_bindings: []
        }')

    # Add agent-squad bindings
    export_data=$(echo "$export_data" | jq \
        --arg ws "$MULTICA_WORKSPACE_ID" \
        'def add_squad_bindings:
            reduce (input | select(.squads != null)) as $squad (
                .;
                reduce ($squad.members[]? | select(.agent_id != null) | {agent_id: .agent_id, agent_name: .name, squad_id: $squad.id, squad_name: $squad.name, role: .role}) as $binding (
                    .;
                    .agent_squad_bindings += [$binding]
                )
            );
        .squads as $squads |
        reduce $squads[] as $squad (
            .;
            ($squad.id as $sid |
            (multica squad member list $sid --output json | fromjson | .[]) as $member |
            select($member.agent_id != null) |
            .agent_squad_bindings += [{
                agent_id: $member.agent_id,
                agent_name: $member.name,
                squad_id: $squad.id,
                squad_name: $squad.name,
                role: $member.role
            }])
        )' 2>/dev/null || echo "$export_data")

    # Fetch agent-skill bindings for each squad
    local bindings_array="[]"
    echo "$squads" | jq -c '.[]' | while read -r squad_line; do
        local squad_id=$(echo "$squad_line" | jq -r '.id')
        local squad_name=$(echo "$squad_line" | jq -r '.name')

        # For each agent in squad, get their bound skills
        multica squad member list "$squad_id" --output json 2>/dev/null | jq -c '.[]? | select(.agent_id != null) | .agent_id' | while read -r agent_id; do
            [[ -z "$agent_id" ]] && continue

            # Get agent details to get skills
            # Note: multica CLI may not have direct skill-binding query, so we'll note this in output
            echo "{\"agent_id\": \"$agent_id\", \"squad_id\": \"$squad_id\", \"squad_name\": \"$squad_name\"}"
        done
    done > /tmp/bindings.txt

    if [[ -f /tmp/bindings.txt ]]; then
        bindings_array=$(jq -Rs 'split("\n") | map(select(length > 0) | fromjson)' /tmp/bindings.txt)
        export_data=$(echo "$export_data" | jq --argjson bindings "$bindings_array" '.agent_squad_bindings = $bindings')
        rm -f /tmp/bindings.txt
    fi

    # Write to file
    local export_file="workspace-export-$(date +%Y%m%d-%H%M%S).json"
    echo "$export_data" | jq '.' > "$export_file"

    echo -e "${GREEN}✅ Exported to $export_file${NC}"
    echo -e "${BLUE}📊 Summary:${NC}"
    echo "$export_data" | jq -r '.summary | "  Agents: \(.agents_count), Squads: \(.squads_count), Skills: \(.skills_count)"'
}

# Sync all skills from config
cmd_sync_skills() {
    local config_file="${1:-skills-config.json}"

    [[ ! -f "$config_file" ]] && {
        echo -e "${RED}❌ Config file not found: $config_file${NC}"
        exit 1
    }

    echo -e "${BLUE}📚 Syncing all skills from '$config_file'...${NC}"

    # Get all existing skills in workspace as name -> id map
    local ws_skills=$(multica skill list --output json 2>/dev/null | jq -r '.[] | "\(.name)|\(.id)"' | sort || true)

    local skills=$(jq -r '.[] | .name' "$config_file" || true)

    if [[ -z "$skills" ]]; then
        echo -e "${RED}❌ No skills found in config${NC}"
        return 1
    fi

    local created=0
    local updated=0
    local skipped=0
    local failed=0

    while IFS= read -r skill_name; do
        [[ -z "$skill_name" ]] && continue

        # Find template directory for this skill
        local template_dir=$(find ../../templates/skills -type d -name "$skill_name" 2>/dev/null | head -1)

        if [[ -z "$template_dir" ]]; then
            echo -e "${YELLOW}  ⚠️  Template not found for: $skill_name${NC}"
            ((skipped++))
            continue
        fi

        # Check if skill exists in workspace
        local skill_id=$(echo "$ws_skills" | grep "^${skill_name}|" | cut -d'|' -f2)

        if [[ -n "$skill_id" ]]; then
            # Skill exists - update all files
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}  [DRY-RUN] Would update skill: $skill_name${NC}"
                find "$template_dir" -type f | while read file; do
                    local rel_path="${file#$template_dir/}"
                    echo -e "${YELLOW}    → file: $rel_path${NC}"
                done
            else
                # Update main content (SKILL.md)
                if [[ -f "$template_dir/SKILL.md" ]]; then
                    if ! multica skill update "$skill_id" --content-file "$template_dir/SKILL.md" 2>/dev/null; then
                        echo -e "${RED}  ❌ Failed to update content for: $skill_name${NC}"
                        ((failed++))
                        continue
                    fi
                fi

                # Update all other files
                find "$template_dir" -type f ! -name "SKILL.md" | while read file; do
                    local rel_path="${file#$template_dir/}"
                    if ! multica skill files upsert "$skill_id" --path "$rel_path" --content-file "$file" 2>/dev/null; then
                        echo -e "${YELLOW}    ⚠️  Failed to update file: $rel_path${NC}"
                    fi
                done

                echo -e "${GREEN}  ✅ Updated: $skill_name${NC}"
                ((updated++))
            fi
        else
            # Skill does not exist - create
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}  [DRY-RUN] Would create skill: $skill_name${NC}"
                find "$template_dir" -type f | while read file; do
                    local rel_path="${file#$template_dir/}"
                    echo -e "${YELLOW}    → file: $rel_path${NC}"
                done
            else
                # Create skill with main content (SKILL.md)
                if [[ ! -f "$template_dir/SKILL.md" ]]; then
                    echo -e "${RED}  ❌ SKILL.md not found for: $skill_name${NC}"
                    ((failed++))
                    continue
                fi

                if ! multica skill create --name "$skill_name" --content-file "$template_dir/SKILL.md" 2>/dev/null; then
                    echo -e "${RED}  ❌ Failed to create: $skill_name${NC}"
                    ((failed++))
                    continue
                fi

                # Get the newly created skill ID
                skill_id=$(multica skill list --output json 2>/dev/null | jq -r ".[] | select(.name == \"$skill_name\") | .id" | head -1)

                if [[ -z "$skill_id" ]]; then
                    echo -e "${RED}  ❌ Failed to get ID for created skill: $skill_name${NC}"
                    ((failed++))
                    continue
                fi

                # Upload all other files
                find "$template_dir" -type f ! -name "SKILL.md" | while read file; do
                    local rel_path="${file#$template_dir/}"
                    if ! multica skill files upsert "$skill_id" --path "$rel_path" --content-file "$file" 2>/dev/null; then
                        echo -e "${YELLOW}    ⚠️  Failed to upload file: $rel_path${NC}"
                    fi
                done

                echo -e "${GREEN}  ✅ Created: $skill_name${NC}"
                ((created++))
            fi
        fi
    done <<< "$skills"

    echo -e "${GREEN}✅ Skills sync complete (created: $created, updated: $updated, skipped: $skipped, failed: $failed)${NC}"
}

# Sync all agents from config and bind their skills
cmd_sync_agents() {
    local config_file="${1:-agents-config.json}"

    [[ ! -f "$config_file" ]] && {
        echo -e "${RED}❌ Config file not found: $config_file${NC}"
        exit 1
    }

    echo -e "${BLUE}👤 Syncing all agents from '$config_file'...${NC}"

    # Get all existing agents in workspace as name -> id map
    local ws_agents=$(multica agent list --output json 2>/dev/null | jq -r '.[] | "\(.name)|\(.id)"' | sort || true)

    local agents=$(jq -r '.agents[] | @json' "$config_file" || true)

    if [[ -z "$agents" ]]; then
        echo -e "${RED}❌ No agents found in config${NC}"
        return 1
    fi

    local created=0
    local updated=0
    local skipped=0
    local failed=0

    while IFS= read -r agent_json; do
        [[ -z "$agent_json" ]] && continue

        local agent_name=$(echo "$agent_json" | jq -r '.name')
        local agent_stem=$(echo "$agent_json" | jq -r '.stem')
        local config_skills=$(echo "$agent_json" | jq -r '.skills[]? // empty')

        # Check if agent exists
        local agent_id=$(echo "$ws_agents" | grep "^${agent_name}|" | cut -d'|' -f2)

        if [[ -z "$agent_id" ]]; then
            # Agent does not exist
            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}  [DRY-RUN] Would create agent: $agent_name${NC}"
                echo "$config_skills" | while read -r skill; do
                    [[ -z "$skill" ]] && continue
                    echo -e "${YELLOW}    → bind skill: $skill${NC}"
                done
            else
                echo -e "${YELLOW}  ⚠️  Agent creation not yet implemented via CLI: $agent_name${NC}"
                ((skipped++))
            fi
        else
            # Agent exists - check and update skills + instructions
            local existing_skills=$(multica agent skills list "$agent_id" --output json 2>/dev/null | jq -r '.[].name' | sort || true)

            # Find agent template file using stem
            local agent_template=$(find ../../templates/agents -name "${agent_stem}.md" 2>/dev/null | head -1)

            if [[ "$DRY_RUN" == "true" ]]; then
                echo -e "${YELLOW}  [DRY-RUN] Would update agent: $agent_name${NC}"

                if [[ -n "$agent_template" ]]; then
                    echo -e "${YELLOW}    → Update instructions from: templates/agents/${agent_stem}.md${NC}"
                else
                    echo -e "${YELLOW}    ⚠️  Template not found for: ${agent_stem}.md${NC}"
                fi

                echo "$config_skills" | while read -r skill; do
                    [[ -z "$skill" ]] && continue

                    if echo "$existing_skills" | grep -q "^${skill}$"; then
                        echo -e "${YELLOW}    ✓ Already bound: $skill${NC}"
                    else
                        echo -e "${YELLOW}    → bind skill: $skill${NC}"
                    fi
                done
            else
                # Update agent's instructions if template exists
                if [[ -n "$agent_template" ]]; then
                    if multica agent update "$agent_id" --instructions "$(cat "$agent_template")" 2>/dev/null; then
                        echo -e "${BLUE}    ℹ️  Updated instructions${NC}"
                    else
                        echo -e "${RED}    ❌ Failed to update instructions${NC}"
                    fi
                fi

                # Update agent's skills
                echo "$config_skills" | while read -r skill; do
                    [[ -z "$skill" ]] && continue

                    if ! echo "$existing_skills" | grep -q "^${skill}$"; then
                        # Skill not bound, add it
                        if multica agent skills add "$agent_id" --skill-names "$skill" 2>/dev/null; then
                            echo -e "${GREEN}    ✅ Bound: $skill${NC}"
                        else
                            echo -e "${RED}    ❌ Failed to bind: $skill${NC}"
                        fi
                    else
                        echo -e "${GREEN}    ✓ Already bound: $skill${NC}"
                    fi
                done

                echo -e "${GREEN}  ✅ Updated: $agent_name${NC}"
                ((updated++))
            fi
        fi
    done <<< "$agents"

    echo -e "${GREEN}✅ Agents sync complete (created: $created, updated: $updated, skipped: $skipped, failed: $failed)${NC}"
}

# Initialize workspace: sync skills, agents, create squads, add members (one-shot)
cmd_init() {
    local config_file="${1:-squad-config.json}"

    [[ ! -f "$config_file" ]] && {
        echo -e "${RED}❌ Config file not found: $config_file${NC}"
        exit 1
    }

    # Full workflow: skills → agents → squads → members
    echo -e "${BLUE}🚀 Initializing workspace (4 steps)...${NC}"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN mode enabled]${NC}"
    fi

    echo ""
    echo -e "${BLUE}Step 1/4: Syncing skills...${NC}"
    cmd_sync_skills "skills-config.json"

    echo ""
    echo -e "${BLUE}Step 2/4: Syncing agents...${NC}"
    cmd_sync_agents "agents-config.json"

    echo ""
    echo -e "${BLUE}Step 3/4: Creating squads...${NC}"
    cmd_create_squads "$config_file"

    echo ""
    echo -e "${BLUE}Step 4/4: Adding squad members...${NC}"
    cmd_sync_squad "$config_file"

    echo ""
    echo -e "${GREEN}✅ Workspace initialization complete!${NC}"
}

# Create all squads from config (internal helper)
cmd_create_squads() {
    local config_file="${1:-squad-config.json}"

    [[ ! -f "$config_file" ]] && {
        echo -e "${RED}❌ Config file not found: $config_file${NC}"
        exit 1
    }

    local squads=$(jq -r '.squads[] | "\(.name)"' "$config_file" || true)

    if [[ -z "$squads" ]]; then
        echo -e "${RED}❌ No squads found in config${NC}"
        return 1
    fi

    local created=0

    while IFS= read -r squad_name; do
        [[ -z "$squad_name" ]] && continue

        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "${YELLOW}  [DRY-RUN] Would create squad: $squad_name${NC}"
        else
            if multica squad create --name "$squad_name" 2>/dev/null; then
                echo -e "${GREEN}  ✅ Created squad: $squad_name${NC}"
                ((created++))
            else
                echo -e "${YELLOW}  ⚠️  Squad may already exist: $squad_name${NC}"
            fi
        fi
    done <<< "$squads"

    echo -e "${GREEN}✅ Squad creation complete (created: $created)${NC}"
}

# Sync squad members and skills
cmd_sync() {
    local squad_id="${1:-}"
    local action="${2:-members}"

    [[ -z "$squad_id" ]] && {
        echo -e "${RED}❌ Usage: $0 sync <squad-id> [members|skills|all]${NC}"
        exit 1
    }

    echo -e "${BLUE}🔄 Syncing squad '$squad_id' ($action)...${NC}"

    case "$action" in
        members)
            echo "  - Listing squad members..."
            multica squad member list "$squad_id" --output json 2>/dev/null | jq '.' || true
            ;;
        skills)
            echo "  - Listing skills..."
            multica skill list --output json 2>/dev/null | jq '.' || true
            ;;
        all)
            echo "  - Listing members and skills..."
            multica squad member list "$squad_id" --output json 2>/dev/null | jq '.' || true
            multica skill list --output json 2>/dev/null | jq '.' || true
            ;;
        *)
            echo -e "${RED}❌ Unknown action: $action${NC}"
            exit 1
            ;;
    esac

    echo -e "${GREEN}✅ Sync complete${NC}"
}

# Clone squad to another workspace
cmd_clone() {
    local from_squad="${1:-}"
    local to_workspace="${2:-}"
    local to_squad_name="${3:-}"

    [[ -z "$from_squad" || -z "$to_workspace" ]] && {
        echo -e "${RED}❌ Usage: $0 clone <squad-id> <target-workspace-id> [squad-name]${NC}"
        exit 1
    }

    [[ -z "$to_squad_name" ]] && to_squad_name=$(multica squad get "$from_squad" --output json 2>/dev/null | jq -r '.name')

    echo -e "${BLUE}📋 Cloning squad '$from_squad' to workspace '$to_workspace'...${NC}"
    echo "   Source: $from_squad (workspace: $MULTICA_WORKSPACE_ID)"
    echo "   Target: $to_squad_name (workspace: $to_workspace)"

    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN] Would clone squad${NC}"
    else
        echo -e "${YELLOW}⚠️  Clone via API not yet implemented in multica CLI${NC}"
        echo "   Use: multica squad get <squad-id> > squad-export.json"
        echo "   Then recreate in target workspace using exported data"
    fi
}

# Sync squad and add/update members
cmd_sync_squad() {
    local config_file="${1:-squad-config.json}"

    [[ ! -f "$config_file" ]] && {
        echo -e "${RED}❌ Config file not found: $config_file${NC}"
        exit 1
    }

    echo -e "${BLUE}👥 Syncing all squads from '$config_file'...${NC}"

    # Cache all agents by name
    local agents_by_name=$(multica agent list --output json 2>/dev/null | jq -r '.[] | "\(.name)|\(.id)"' || true)

    if [[ -z "$agents_by_name" ]]; then
        echo -e "${RED}❌ No agents found in workspace${NC}"
        return 1
    fi

    local squads=$(jq -r '.squads[] | @json' "$config_file" || true)

    if [[ -z "$squads" ]]; then
        echo -e "${RED}❌ No squads found in config${NC}"
        return 1
    fi

    local total_added=0

    while IFS= read -r squad_json; do
        [[ -z "$squad_json" ]] && continue

        local squad_name=$(echo "$squad_json" | jq -r '.name')
        local members=$(echo "$squad_json" | jq -r '.members[]? | @json')

        echo -e "${BLUE}  Squad: $squad_name${NC}"

        # Get squad ID by name
        local squad_id=$(multica squad list --workspace-id "$MULTICA_WORKSPACE_ID" --output json 2>/dev/null | \
            jq -r ".[] | select(.name == \"$squad_name\") | .id" | head -1)

        if [[ -z "$squad_id" ]]; then
            echo -e "${YELLOW}  ⚠️  Squad not found: $squad_name${NC}"
            continue
        fi

        # Get squad members: build member_id -> role map
        local squad_members=$(multica squad member list "$squad_id" --output json 2>/dev/null | jq -r '.[] | "\(.member_id)|\(.role)"' || true)

        echo "$members" | while read -r member_json; do
            [[ -z "$member_json" ]] && continue

            local agent_name=$(echo "$member_json" | jq -r '.agent_name')
            local role=$(echo "$member_json" | jq -r '.role')

            # Resolve agent ID by name from cache
            local agent_id=$(echo "$agents_by_name" | grep "^${agent_name}|" | cut -d'|' -f2)

            if [[ -z "$agent_id" ]]; then
                echo -e "${YELLOW}    ⚠️  Agent not found: $agent_name${NC}"
                continue
            fi

            # Check if member_id exists in squad (regardless of role)
            if echo "$squad_members" | grep -q "^${agent_id}|"; then
                # Member exists, check if role needs update
                local existing_role=$(echo "$squad_members" | grep "^${agent_id}|" | cut -d'|' -f2)

                if [[ "$existing_role" == "$role" ]]; then
                    echo -e "${GREEN}    ✓ Already member: $agent_name (role: $role)${NC}"
                else
                    if [[ "$DRY_RUN" == "true" ]]; then
                        echo -e "${YELLOW}    [DRY-RUN] Would update: $agent_name role from '$existing_role' to '$role'${NC}"
                    else
                        if multica squad member update "$squad_id" --member-id "$agent_id" --role "$role" 2>/dev/null; then
                            echo -e "${GREEN}    ✅ Updated: $agent_name role to $role${NC}"
                            ((total_added++))
                        else
                            echo -e "${YELLOW}    ⚠️  Failed to update: $agent_name${NC}"
                        fi
                    fi
                fi
            else
                # Member does not exist, add
                if [[ "$DRY_RUN" == "true" ]]; then
                    echo -e "${YELLOW}    [DRY-RUN] Would add: $agent_name as $role${NC}"
                else
                    if multica squad member add "$squad_id" --member-id "$agent_id" --role "$role" 2>/dev/null; then
                        echo -e "${GREEN}    ✅ Added: $agent_name as $role${NC}"
                        ((total_added++))
                    else
                        echo -e "${YELLOW}    ⚠️  Failed to add: $agent_name${NC}"
                    fi
                fi
            fi
        done
    done <<< "$squads"

    echo -e "${GREEN}✅ Squad sync complete (members added: $total_added)${NC}"
}

# Show help
show_help() {
    cat << 'EOF'
multica-sync.sh — 统一 Multica 工作区同步 / Unified Multica workspace sync

用法 / Usage:
  ./multica-sync.sh <command> [options]

命令 / Commands:
  list                          列出小队 / List squads
  export                        导出工作区配置 / Export entire workspace config
  init [config-file]            一键初始化工作区（4步：skills→agents→squads→members）
                                Initialize workspace in one command (default: squad-config.json)
  sync-skills [config-file]     同步所有 skills / Sync all skills (default: skills-config.json)
  sync-agents [config-file]     同步所有 agents + 绑定 skills / Sync agents and bind skills (default: agents-config.json)
  sync-squad [config-file]      为 squads 添加成员 / Add members to all squads (default: squad-config.json)
  sync <squad-id> [members|skills|all]
                                 查看小队成员或技能 / View members or skills
  clone <squad-id> <target-workspace-id> [squad-name]
                                 跨工作区复制小队 / Clone squad to another workspace

全局选项 / Global options:
  --config FILE                  配置文件 / Config file (default: config.local.json)
  --dry-run                      仅预览，不执行 / Preview only, don't execute
  --help                         显示帮助 / Show this help

环境变量 / Environment variables:
  MULTICA_WORKSPACE_ID           工作区 ID / Workspace ID
  MULTICA_DRY_RUN                设为 true 进行预览 / Set to true for dry-run
  MULTICA_CONFIG_FILE            配置文件路径 / Config file path

示例 / Examples:
  # 列出小队
  ./multica-sync.sh list

  # 导出整个工作区配置（agents、squads、skills 及关系）
  ./multica-sync.sh export
  # → workspace-export-20261003-120530.json

  # 一键初始化工作区（先预览）
  export MULTICA_DRY_RUN="true"
  ./multica-sync.sh init

  # 真正执行（无 DRY-RUN）
  unset MULTICA_DRY_RUN
  ./multica-sync.sh init

  # 或分步执行
  export MULTICA_DRY_RUN="true"
  ./multica-sync.sh sync-skills
  ./multica-sync.sh sync-agents
  ./multica-sync.sh sync-squad
EOF
}

# Main
main() {
    check_deps

    if [[ $# -eq 0 || "$1" == "--help" || "$1" == "help" ]]; then
        show_help
        exit 0
    fi

    # Parse global options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    load_config

    local cmd="$1"
    shift || true

    case "$cmd" in
        list)
            cmd_list "$@"
            ;;
        export)
            cmd_export "$@"
            ;;
        sync-skills)
            cmd_sync_skills "$@"
            ;;
        sync-agents)
            cmd_sync_agents "$@"
            ;;
        init)
            cmd_init "$@"
            ;;
        sync-squad)
            cmd_sync_squad "$@"
            ;;
        sync)
            cmd_sync "$@"
            ;;
        clone)
            cmd_clone "$@"
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $cmd${NC}"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
