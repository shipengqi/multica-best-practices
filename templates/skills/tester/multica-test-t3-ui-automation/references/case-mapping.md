# Functional Test Case → UI Test 1:1 Mapping

## Case Count

`N = len(json["functional"])`  
Generate exactly `N` test functions; test collection count must equal `N`.

`case_id` → test method name: replace non-alphanumeric chars with `_`, ensuring legality and uniqueness.

## Mapping Steps

| Functional Case Field | UI Test Script |
| --- | --- |
| `preconditions` | fixture or test setup; use permission semantics for login, passwords from env vars only |
| `steps[i]` | one Playwright action (click/fill/select/wait) |
| `expected_results[i]` | `expect(...)` or `assert`; inline after the corresponding step in the same test |

## Locator Priority

Priority order: `get_by_role` → `get_by_label` → `get_by_text` → `get_by_placeholder`.  
No unsupported CSS selectors without page evidence.  
If still not found after opening `page_url` → `@pytest.mark.blocked` + skip.

## Don't

- Assert "API returned 200" in UI test (unless the step is literally reading a page notification)
- Skip steps just to make the test pass
- Share mutable global state across test cases
