---
screen: "muted-users"
status: documented

identify_by:
  - { element: "Heading", label: "Muted Users" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Muted Users" element_type="button"'

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a user row"
    condition: "has muted users"
  - screen: "(timeline, not preferences)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [settings, moderation]
---

# Muted Users

List of users the current account has muted.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Muted Users | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to timeline (not Preferences) |
| Group | Empty list | (none) | Shown when no users are muted |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Group label "Empty list" | No muted users |
| Populated | User row elements visible | Has muted users |

## Quirks

- Back button navigates to the main timeline, not back to Preferences. The account menu closes when navigating through sub-screens.
