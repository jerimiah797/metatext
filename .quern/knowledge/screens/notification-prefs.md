---
screen: "notification-prefs"
status: documented

landmarks:
  - { element: "Heading", label: "Notifications" }
  - { element: "CheckBox", label: "Include pictures" }

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
| CheckBox | Include pictures | `notifications.include-pictures` | value="1" = show images in push notifications |
| CheckBox | Include account name | `notifications.include-account-name` | value="0" = hide account name in pushes |

### Sounds (section header: "Sounds")

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Sounds | (none) | Section header |
| CheckBox | Follow | `notifications.sound.follow` | Sound on follow notification |
| CheckBox | Mention | `notifications.sound.mention` | Sound on mention notification |
| CheckBox | Reblog | `notifications.sound.reblog` | Sound on boost notification |
| CheckBox | Favorite | `notifications.sound.favourite` | Sound on favorite notification |
| CheckBox | Poll | `notifications.sound.poll` | Sound on poll result notification |
| CheckBox | Follow Request | `notifications.sound.followRequest` | Sound on follow request notification |
| CheckBox | Subscription | `notifications.sound.status` | Sound on subscription notification |
| CheckBox | (empty label) | `notifications.sound.update` | Update notification type — label is empty |

## Quirks

- All elements have `notifications.*` identifiers.
- The nav bar title "Notifications" is the same as the Notifications tab — use `identify_by` with "Include pictures" checkbox to disambiguate.
- Sound toggle labels reuse the same names as Notification Types screen (Follow, Mention, Reblog, etc.) — different screens despite similar content.
- "Reblog" terminology used instead of "Boost" (API terminology).
