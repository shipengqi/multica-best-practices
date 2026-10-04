# Coverage Checklist — T1 Pre-Generation Self-Check

> **Purpose**: Self-check every dimension before finalizing test cases (see `multica-test-t1-design` Step 5).
> **For T2 coverage gaps**: Use `multica-test-t2-coverage`, not this checklist.

For each module, verify that all three dimensions are fully covered before marking cases complete.

---

## Dimension 1: Happy Path & Branch Coverage

### Normal Flow (Happy Path)
- [ ] Core business main path complete
- [ ] Each conditional branch (if/else) covered once
- [ ] Each option (dropdown, radio, checkbox) value tested
- [ ] Status transitions in normal sequence
- [ ] Page navigation correct

### Alternative Branches & State Transitions
- [ ] If-else branches each covered
- [ ] State transition A → B → C → D
- [ ] Reverse/rollback state transition D → C → A (if allowed)
- [ ] Skip middle state (if allowed)
- [ ] Repeated operation on terminal state (blocked or no-op?)

### Error Scenarios
- [ ] Network timeout / connection lost
- [ ] Server error (500)
- [ ] Resource not found (404)
- [ ] Access denied (403/401)
- [ ] Rate limit (429)
- [ ] Validation failure (wrong input type, missing required field)
- [ ] Data conflict (duplicate, already exists)

### Permission & Access Control
- [ ] Admin can perform operation
- [ ] Normal user can perform operation
- [ ] Guest/unauthenticated access blocked or limited
- [ ] Read-only user cannot modify
- [ ] Cross-department/cross-role data visibility correct

### Data Updates & Consistency
- [ ] Create new item → list updates
- [ ] Edit item → related fields refresh
- [ ] Delete item → references handled (cascade or error?)
- [ ] Master-detail operations (parent change → child affected?)
- [ ] Multiple filter + sort + pagination combinations

### Concurrency & Edge Cases
- [ ] Rapid successive clicks → submit once or fail gracefully?
- [ ] Browser back button → state consistent?
- [ ] Multiple tabs with same page open → data synced?
- [ ] Duplicate submission → blocked or idempotent?

---

## Dimension 2: Boundary & Input Validation

### Numeric Input
- [ ] Minimum valid value
- [ ] Maximum valid value
- [ ] Min - 1 (just below valid range)
- [ ] Max + 1 (just above valid range)
- [ ] Zero
- [ ] Negative numbers
- [ ] Decimal precision (rounding vs truncation)

### String Input
- [ ] Empty string
- [ ] Single character
- [ ] Maximum length
- [ ] Maximum length + 1
- [ ] Very long text (10× max length)
- [ ] Whitespace only
- [ ] Special characters (!@#$%^&*()_+)
- [ ] HTML tags (`<script>`, `<img onerror>`) — XSS test
- [ ] SQL injection patterns (`' OR 1=1 --`) — injection test
- [ ] Unicode (emoji, non-ASCII languages)
- [ ] Newlines / control characters

### Lists & Collections
- [ ] Empty list
- [ ] Single element
- [ ] Maximum count
- [ ] Maximum + 1 (overflow?)
- [ ] Large dataset (performance boundary)

### Enum / Option Values
- [ ] Each enum value once
- [ ] Non-existent enum value
- [ ] Null / undefined enum
- [ ] Wrong type for enum (number vs string)

### Dates & Time
- [ ] Current timestamp
- [ ] Past date (e.g., 1970-01-01)
- [ ] Far future (e.g., 2099-12-31)
- [ ] Leap year Feb 29
- [ ] Time zone edge cases
- [ ] Invalid date format (2026/13/01, 2026-02-30)
- [ ] Midnight / end of day

### File Upload
- [ ] Empty file (0 bytes)
- [ ] Boundary size (exactly at limit)
- [ ] Over limit
- [ ] Unsupported format
- [ ] Special characters in filename
- [ ] Corrupted file
- [ ] Multiple files simultaneously

### Pagination
- [ ] page = 1 (first page)
- [ ] page = total (last page)
- [ ] page = 0 or negative
- [ ] page > total pages
- [ ] pageSize = 1
- [ ] pageSize = max
- [ ] pageSize = 0 or negative
- [ ] pageSize > max

### Required Fields
- [ ] All required fields empty
- [ ] Only some required fields filled
- [ ] Required field with whitespace only
- [ ] No fields provided at all

### Uniqueness Constraints
- [ ] Duplicate submit (same data)
- [ ] Concurrent creation of same data
- [ ] Modify to already-existing unique value

---

## Dimension 3: UI & Presentation (If Applicable)

### Element Completeness
- [ ] All buttons present and labeled correctly
- [ ] All input fields present with correct placeholders
- [ ] All text labels and headings present
- [ ] All icons / images render
- [ ] All links navigate correctly
- [ ] No orphaned or leftover elements

### Layout & Alignment
- [ ] Horizontal alignment matches design
- [ ] Vertical alignment matches design
- [ ] Spacing (margin/padding) consistent
- [ ] Element dimensions match spec
- [ ] Responsive breakpoints working (mobile, tablet, desktop)
- [ ] Table columns sized correctly

### Typography & Color
- [ ] Font family, size, weight match design system
- [ ] Text color matches palette
- [ ] Background / border colors correct
- [ ] Spacing / whitespace adequate
- [ ] Line height readable

### Interactive States
- [ ] Default state (unclicked, unfocused)
- [ ] Hover state
- [ ] Focus state (keyboard/screen reader)
- [ ] Active/pressed state
- [ ] Disabled state (visually distinct, not clickable)
- [ ] Checked/selected state
- [ ] Loading state (spinner, disabled buttons)
- [ ] Error state (validation message, red highlight)

### Page States
- [ ] Initial state (page just loaded, no data yet)
- [ ] Loading state (spinner visible, actions disabled)
- [ ] Empty state (no results; placeholder image + message)
- [ ] Error state (error icon + retry action)
- [ ] Success state (data displayed correctly)
- [ ] Unexpected state (recovery UX clear?)

### Responsive Adaptation
- [ ] Desktop 1920×1080 complete and readable
- [ ] Desktop 1440×900 complete
- [ ] Desktop 1366×768 no broken layout
- [ ] Tablet 768×1024 responsive layout
- [ ] Mobile 375×667 readable and usable
- [ ] Zoom 150%/200% — no severe corruption

### Accessibility & Keyboard
- [ ] Tab order logical
- [ ] Enter key triggers primary action (form submit)
- [ ] All main actions doable via keyboard
- [ ] Images have alt text
- [ ] Form labels correctly associated with inputs
- [ ] Color not the only visual cue (high contrast)

---

## API & Interface Coverage (Supplementary)

### Happy Path & Error Scenarios
- [ ] Successful request → correct data + business code
- [ ] Resource not found → 404 + error code
- [ ] Unauthorized → 401 + error response
- [ ] Forbidden → 403 + error response
- [ ] Validation failure → 400 + error details
- [ ] Server error → 500
- [ ] Rate limit → 429 + retry hint

### Request Boundary Testing
- [ ] Required parameter missing
- [ ] Parameter type mismatch
- [ ] Parameter format invalid (date, email, URL)
- [ ] Parameter null / empty
- [ ] Parameter exceeds max length
- [ ] Parameter at min/max boundary
- [ ] Parameter invalid enum value
- [ ] Extra undocumented parameters
- [ ] Missing / incorrect headers

### Response Validation
- [ ] All required fields present
- [ ] No undocumented extra fields
- [ ] Field types match spec (string, number, boolean, array)
- [ ] Field format correct (date, currency, URL)
- [ ] Nested objects structure correct
- [ ] Null handling correct (null vs empty string vs empty array)
- [ ] Arrays: empty, single element, multiple elements
- [ ] Pagination fields (page, total, pageSize) populated
- [ ] Business status codes match spec

---

## Pre-Delivery Checklist

- [ ] All cases have unique IDs (TC-F-xxx, TC-I-yyy)
- [ ] All cases link back to source AC
- [ ] All cases have concrete, executable steps (no vague wording)
- [ ] All preconditions state permission requirements (no hardcoded accounts)
- [ ] All cases have clear expected results linked to AC/spec
- [ ] No duplicate cases (same scenario, same AC, same expected outcome)
- [ ] Coverage report includes traceability table (AC → design → test case)
- [ ] Coverage report includes dimension matrix (what is tested, what is not)
- [ ] At-risk or untested AC clearly documented
- [ ] Case count and priority distribution reasonable for requirement size
