# Zero-to-Framework Template (pytest + Playwright + Allure)

When the target directory is empty or missing, the Agent **MUST create** the following structure as-is (replace `{JIRA_KEY}` as needed).

```text
<target_dir>/
├── README.md
├── requirements.txt
├── pytest.ini
├── conftest.py
├── config/
│   ├── env.yaml.example
│   └── env.yaml              # gitignore; base_url from issue comment deploy/page_url
├── tests/
│   └── __init__.py
├── artifacts/
└── .gitignore
```

## requirements.txt

```text
pytest>=8.0
playwright>=1.45
pytest-playwright>=0.5
PyYAML>=6.0
allure-pytest>=2.13
python-dotenv>=1.0
```

## pytest.ini

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
addopts = -ra --strict-markers
markers =
    ui: UI automation
    blocked: missing locator or data
```

## conftest.py (key points)

- `pytest_playwright` `page` fixture
- session-level read of `base_url` from `config/env.yaml`
- Never hardcode credentials in conftest; get login values from environment variables

## config/env.yaml.example

```yaml
base_url: "https://replace-from-issue-comment"
browser: chromium
headless: true
timeout_ms: 30000
```

## .gitignore

```text
.venv/
__pycache__/
.pytest_cache/
config/env.yaml
.env
artifacts/allure-results/
artifacts/allure-report/
```

## README.md must include

```text
Source: 1:1 from multica-test-t1-design functional JSON
Run: .venv/Scripts/pytest tests/ --alluredir artifacts/allure-results
```
