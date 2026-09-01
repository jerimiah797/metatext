---
screen: "add-filter"
status: documented

landmarks:
  - { element: "Group", identifier: "Add New Filter" }
  - { element: "Heading", label: "Add New Filter" }
  - { element: "TextField", identifier: "filter.title.field" }

identify_by:
  - { element: "Group", identifier: "Add New Filter", role_description: "Nav bar" }
  - { element: "Heading", label: "Add New Filter" }
  - { element: "TextField", identifier: "filter.title.field" }

reachable_from:
  - screen: "[[screens/filters]]"
    action: 'tap_element label="Add" element_type="button"'

leads_to:
  - screen: "[[screens/filters]]"
    action: 'tap_element label="Filters" element_type="button"'
  - screen: "[[screens/filters]]"
    action: 'tap_element identifier="filter.save" element_type="button"'
    condition: "after filling in required fields"

preconditions:
  - "logged in"

tags: [settings, filters]
---

# Add New Filter

Form for creating a new content filter (v2). Well-instrumented with accessibility identifiers.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Add New Filter` | Nav bar with identifier |
| Heading | Add New Filter | (none) | Nav bar title |
| Button | Filters | `BackButton` | Back to filters list |
| Button | Add | `filter.save` | Top right, saves the filter. Disabled until required fields are filled. |

### Filter Name Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Filter Name | (none) | Section header |
| TextField | (none) | `filter.title.field` | Filter name input, placeholder "Filter Name" |

### Action Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Action | (none) | Section header |
| TabGroup | (none) | `filter.action.picker` | Warn/Hide action picker |

### Expiration

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| CheckBox | Never expires | `filter.never-expires.toggle` | value="1" = never expires |

### Filter Contexts Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Filter contexts | (none) | Section header |
| CheckBox | Home timeline | `filter.context.home` | Apply to home timeline |
| CheckBox | Notifications | `filter.context.notifications` | Apply to notifications |
| CheckBox | Public timelines | `filter.context.public` | Apply to local/federated timelines |
| CheckBox | Conversations | `filter.context.thread` | Apply to thread/conversation views |
| CheckBox | Profiles | `filter.context.account` | Apply to profile views |

### Keywords Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Keywords | (none) | Section header |
| Button | Add Keyword | (none) | Add a keyword to the filter |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Title field placeholder visible, Add button disabled | Initial state |
| Filled | Title entered, at least one context selected, Add button enabled | Ready to save |

## Quirks

- This is a Filters v2 screen — only shown when "Use new filter format" is enabled on the Filters screen.
- Most elements have accessibility identifiers (good instrumentation from our v2 work).
- The "Add" save button (`filter.save`) has the same label as the "Add" button on the Filters list — use the identifier to disambiguate.
- Context toggles all default to off — at least one must be selected.
