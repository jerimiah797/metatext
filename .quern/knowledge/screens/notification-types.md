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
| CheckBox | Follow | `notification-types.follow` | value="1" = enabled |
| CheckBox | Favorite | `notification-types.favourite` | value="1" = enabled |
| CheckBox | Reblog | `notification-types.reblog` | value="1" = enabled |
| CheckBox | Mention | `notification-types.mention` | value="1" = enabled |
| CheckBox | Follow Request | `notification-types.follow-request` | value="1" = enabled |
| CheckBox | Poll | `notification-types.poll` | value="1" = enabled |
| CheckBox | Subscription | `notification-types.status` | value="1" = enabled |

## Quirks

- All toggles have `notification-types.*` identifiers.
- "Reblog" is used here instead of "Boost" (API terminology vs UI terminology).
- All toggles default to enabled.
