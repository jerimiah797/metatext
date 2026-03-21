---
screen: "notification-prefs"
status: documented

identify_by:
  - { element: "Heading", label: "Notifications" }
  - { element: "CheckBox", label: "Include pictures" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Notifications" element_type="button"'
    condition: "in App Preferences section, scroll down if needed"

leads_to:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'

preconditions:
  - "logged in"

tags: [settings]
---

# Notifications (Push Notification Preferences)

Configures push notification appearance and per-type sounds. Not to be confused with the Notifications tab or the Notification Types screen.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Notifications | (none) | Nav bar title |
| Button | Preferences | `BackButton` | Back to Preferences |

### General Settings

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| CheckBox | Include pictures | (none) | value="1" = show images in push notifications |
| CheckBox | Include account name | (none) | value="0" = hide account name in pushes |

### Sounds (section header: "Sounds")

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Sounds | (none) | Section header |
| CheckBox | Follow | (none) | Sound on follow notification |
| CheckBox | Mention | (none) | Sound on mention notification |
| CheckBox | Reblog | (none) | Sound on boost notification |
| CheckBox | Favorite | (none) | Sound on favorite notification |
| CheckBox | Poll | (none) | Sound on poll result notification |
| CheckBox | Follow Request | (none) | Sound on follow request notification |
| CheckBox | Subscription | (none) | Sound on subscription notification |
| CheckBox | (empty label) | (none) | Unknown notification type — label is empty |

## Quirks

- No identifiers on any elements.
- The nav bar title "Notifications" is the same as the Notifications tab — use `identify_by` with "Include pictures" checkbox to disambiguate.
- Sound toggle labels reuse the same names as Notification Types screen (Follow, Mention, Reblog, etc.) — different screens despite similar content.
- One sound toggle has an empty label — possibly a notification type not yet labeled in the app.
- "Reblog" terminology used instead of "Boost" (API terminology).
