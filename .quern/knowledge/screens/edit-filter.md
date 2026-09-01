---
screen: "edit-filter"
status: documented

landmarks:
  - { element: "Group", identifier: "Edit Filter" }
  - { element: "Heading", label: "Edit Filter" }
  - { element: "Button", identifier: "filter.save", label: "Save Changes" }

identify_by:
  - { element: "Group", identifier: "Edit Filter", role_description: "Nav bar" }
  - { element: "Heading", label: "Edit Filter" }
  - { element: "Button", label: "Save Changes", identifier: "filter.save" }

reachable_from:
  - screen: "[[screens/filters]]"
    action: "tap a filter row button"

leads_to:
  - screen: "[[screens/filters]]"
    action: 'tap_element label="Filters" element_type="button"'
  - screen: "[[screens/filters]]"
    action: 'tap_element identifier="filter.save" element_type="button"'

preconditions:
  - "logged in"

tags: [settings, filters]
---

# Edit Filter

Form for editing an existing content filter (v2). Same layout as [[screens/add-filter]] but pre-populated with the filter's current values.

## Key Differences from Add Filter

| Field | Add Filter | Edit Filter |
|---|---|---|
| Nav bar title | "Add New Filter" | "Edit Filter" |
| Nav bar identifier | `Add New Filter` | `Edit Filter` |
| Save button label | "Add" | "Save Changes" |
| Save button state | Disabled until filled | Enabled (existing data) |
| Keywords | Empty, just "Add Keyword" button | Existing keywords shown with indexed identifiers |

## Key Elements

Same as [[screens/add-filter]], plus:

### Existing Keywords

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| TextField | (none) | `filter.keyword.{N}.field` | Keyword text, indexed from 0. Has "Delete" custom action. |
| CheckBox | Whole word | `filter.keyword.{N}.whole-word` | Whole word match toggle, indexed. Has "Delete" custom action. |
| Button | Add Keyword | (none) | Add another keyword |

## Quirks

- Keyword fields use indexed identifiers: `filter.keyword.0.field`, `filter.keyword.1.field`, etc.
- Both the keyword field and its "Whole word" toggle share the same "Delete" custom action — either can be used to delete that keyword.
- The save button identifier (`filter.save`) is the same as on the Add screen — the label differs ("Save Changes" vs "Add").
