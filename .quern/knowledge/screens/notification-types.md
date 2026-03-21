---
screen: "notification-types"
status: documented

identify_by:
  - { element: "Heading", label: "Notification Types" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Notification Types" element_type="button"'

leads_to:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'

preconditions:
  - "logged in"

tags: [settings]
---

# Notification Types

Toggle which notification types are shown. Each type is a CheckBox that can be enabled/disabled.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Notification Types | (none) | Nav bar title |
| Button | Preferences | `BackButton` | Back button |
| CheckBox | Follow | (none) | value="1" = enabled |
| CheckBox | Favorite | (none) | value="1" = enabled |
| CheckBox | Reblog | (none) | value="1" = enabled |
| CheckBox | Mention | (none) | value="1" = enabled |
| CheckBox | Follow Request | (none) | value="1" = enabled |
| CheckBox | Poll | (none) | value="1" = enabled |
| CheckBox | Subscription | (none) | value="1" = enabled |

## Quirks

- No identifiers on any elements.
- "Reblog" is used here instead of "Boost" (API terminology vs UI terminology).
- All toggles default to enabled.
