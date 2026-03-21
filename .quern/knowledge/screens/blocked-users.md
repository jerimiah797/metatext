---
screen: "blocked-users"
status: documented

identify_by:
  - { element: "Heading", label: "Blocked Users" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Blocked Users" element_type="button"'

leads_to:
  - screen: "(timeline, not preferences)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [settings, moderation]
---

# Blocked Users

List of users the current account has blocked.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Blocked Users | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to timeline (not Preferences) |
| Group | Empty list | (none) | Shown when no users are blocked |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Group label "Empty list" | No blocked users |
| Populated | User row elements visible | Has blocked users |

## Quirks

- Same navigation quirk as Muted Users — back goes to timeline, not Preferences.
