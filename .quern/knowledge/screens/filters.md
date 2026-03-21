---
screen: "filters"
status: documented

identify_by:
  - { element: "Group", identifier: "Filters", role_description: "Nav bar" }
  - { element: "Heading", label: "Filters" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Filters" element_type="button"'

leads_to:
  - screen: "[[screens/add-filter]]"
    action: 'tap_element label="Add" element_type="button"'
  - screen: "[[screens/edit-filter]]"
    action: "tap a filter row button"
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'
    condition: "Back button label shows 'Preferences'"

preconditions:
  - "logged in"

tags: [settings, filters]
---

# Filters

Manages content filters for the current account. Supports both v1 (keyword) and v2 (keyword + action) filter formats.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Filters` | Nav bar with identifier |
| Heading | Filters | (none) | Nav bar title |
| Button | Preferences | `BackButton` | Back button, label shows parent screen name |
| Button | Edit | (none) | Top right, enables delete mode on filter rows |
| CheckBox | Use new filter format, Requires Mastodon 4.0 or GoToSocial 0.17+ | (none) | v2 toggle. value="1" = v2 enabled. |
| Button | Add | (none) | Add a new filter |
| Heading | Active | (none) | Section header for active filters |
| Heading | Expired | (none) | Section header for expired filters (if any) |
| Button | {filter title}, {keywords}, {action} | (none) | Filter row. Label contains title, keywords, and action (Warn/Hide). Has "Delete" custom action. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| v2 enabled | "Use new filter format" value="1" | Shows v2 filters with Warn/Hide actions |
| v1 mode | "Use new filter format" value="0" | Shows v1 keyword-only filters |
| Empty | No filter row buttons, only "Add" button | No filters configured |
| Has filters | Filter row buttons visible under "Active"/"Expired" headings | Filters exist |
| Edit mode | "Done" button replaces "Edit" | After tapping Edit, delete controls appear |

## Dynamic Content

Filter rows show: filter title, keyword list, and action type (Warn or Hide for v2). Each filter row is tappable to edit and has a "Delete" custom action.

## Quirks

- The v2 toggle label includes the subtitle text: "Use new filter format, Requires Mastodon 4.0 or GoToSocial 0.17+".
- Filter rows have no identifier — located by label which combines title, keywords, and action.
- When connected to a server that doesn't support v2 filters, the toggle may trigger a 404 fallback to v1.
