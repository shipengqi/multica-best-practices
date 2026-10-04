# Test Case Templates

## Executability & Traceability (Mandatory)

- **Precondition**: Write permission requirements (e.g., "user with [Module/Feature] permission"), NOT hardcoded usernames or passwords. Use placeholder names like `<test_account>` that teams resolve via their test data configuration.
- **Steps**: Write actual menu paths, real API endpoints, and data aliases (e.g., `order_id=A_ant_ok`). Every step must be executable.
- **Expected result**: Link back to AC or PRD clause. Reference exact field names and system states from the requirement.
- **Traceability**: Include AC ID (e.g., AC-1, PROJ-123 AC-A) so the case maps back to its source requirement.

## Functional Test Case Template

```
=== Functional Test Case ===

Case ID: TC-F-{module}-{sequence}
Module: {system/domain/feature, use / for hierarchy}
Title: {concise description of test scenario}

Preconditions:
  1. Logged in with account having [{module/feature}] permission
  2. Test data: {alias}={key values} (e.g., order_id=A_ant_ok, count=2, field_x=1.5)
  3. {data ready / calculation completed}

Test Data: {key inputs matching AC}
Case Type: [UI check / functional flow / input validation / boundary / error scenario]
Priority: [P1 critical / P2 normal / P3 edge case] (required, no P0 default)
Traceability: [AC-1 / PRD §n / Issue AC clause]

Test Steps:
  1. Navigate to {system} → {menu path}, wait for load
  2. {perform business operation}
  3. {verify result}

Expected Results:
  1. {step 1 outcome}
  2. {step 2 outcome}
  3. {step 3 outcome}
---
```

### Functional Test Case Example (Permission-Based Precondition + Executable Path)

```
=== Functional Test Case ===

Case ID: TC-F-ORDER-001
Module: Order Management / Tag / Query & Tagging
Title: Tag order when Count > 0 and coverage > 1mm; verify searchability

Preconditions:
  1. Logged in with account having [Order Management / Query] permission
  2. Test data: order_A_ok (count=2, field_x=1.5)
  3. Tag calculation completed

Test Data: Count=2, field_x=1.5 (AC scenario A)
Case Type: Functional flow
Priority: P1
Traceability: PROJ-123 AC-A

Test Steps:
  1. Navigate to System A → Order Management → Query, wait for load
  2. Select [Tag A] filter (if UI text differs, use actual label), wait for list refresh
  3. Search by order ID (order_A_ok), verify tag display

Expected Results:
  1. Query page loaded
  2. Tag filter applied, list refreshed successfully
  3. Order appears in results with [Tag A] label displayed
---
```

## API Test Case Template

```
=== API Test Case ===

Case ID: TC-I-{module}-{sequence}
API Name: {method} {endpoint URL}
Title: {concise description of test scenario}
Method: GET/POST/PUT/DELETE

Preconditions:
  1. {e.g., test account registered and active; account from test data config, not hardcoded}
  2. {service running normally}

Request Parameters:
  {
    "param_name": "{param_value}",  // description
    "field_x": "{from_test_config}"  // reference to test data, not literal value
  }

Expected HTTP Status: {code}
Expected Business Code: {code or "N/A"}

Expected Response:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "field_name": "<type, description>"
  }
}
```

Validation Points:
  - code = 0 (indicates success)
  - data.field matches requirement specification
  - no missing or extra fields
---
```

### API Test Case Example

```
=== API Test Case ===

Case ID: TC-I-AUTH-001
API Name: POST /api/v1/user/login
Title: Verify successful login with correct credentials

Preconditions:
  1. Test account exists and is active (from test data config)
  2. Auth service running

Request Parameters:
  {
    "email": "<test_account_email>",
    "password": "<from_secure_test_config>"
  }

Expected HTTP Status: 200
Expected Business Code: 0 (success)

Expected Response:
```json
{
  "code": 0,
  "message": "success",
  "data": {
    "token": "<JWT string>",
    "user": {
      "id": "<integer>",
      "email": "<string>",
      "name": "<string>"
    }
  }
}
```

Validation Points:
  - code = 0
  - token is non-empty string
  - user.id is numeric type
  - user.email matches request email
  - response has no extra fields not in specification
  - all fields match API contract in design document
---
```

## Coverage Notes

- **Functional cases**: Cover UI flows, business logic, user interactions, permission rules, error handling
- **API cases**: Verify contract compliance (happy path + error cases), request/response validation, HTTP status codes
- **Data**: Use test data aliases and placeholders, never hardcoded production values or personal credentials
- **Preconditions**: State required permissions, system state, or data setup in abstract terms; executors map to their actual test configurations
