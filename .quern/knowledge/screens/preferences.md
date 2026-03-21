---
screen: "preferences"
status: documented

identify_by:
  - { element: "Heading", label: "Preferences" }
  - { element: "Button", label: "Back", identifier: "BackButton" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Preferences" element_type="button"'

leads_to:
  - screen: "[[screens/filters]]"
    action: 'tap_element label="Filters" element_type="button"'
  - screen: "[[screens/notification-types]]"
    action: 'tap_element label="Notification Types" element_type="button"'
  - screen: "[[screens/muted-users]]"
    action: 'tap_element label="Muted Users" element_type="button"'
  - screen: "[[screens/blocked-users]]"
    action: 'tap_element label="Blocked Users" element_type="button"'
  - screen: "[[screens/blocked-domains]]"
    action: 'tap_element label="Blocked Domains" element_type="button"'
  - screen: "[[screens/app-icon]]"
    action: 'tap_element label_prefix="App Icon" element_type="button"'
  - screen: "[[screens/notification-prefs]]"
    action: 'tap_element label="Notifications" element_type="button"'
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [settings]
---

# Preferences

App and account preferences. Divided into two sections: per-account server preferences and local app preferences.

## Key Elements

### Per-Account Section (header: @handle@instance)

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | @handle@instance | (none) | Section header, shows current account |
| Button | Filters | (none) | Manage content filters |
| Button | Notification Types | (none) | Configure notification types |
| Button | Muted Users | (none) | View/manage muted users |
| Button | Blocked Users | (none) | View/manage blocked users |
| Button | Blocked Domains | (none) | View/manage blocked domains |
| CheckBox | Use preferences from server | (none) | value="1" = on. When on, server prefs are used and local overrides are disabled. |
| PopUpButton | Default visibility, {value} | (none) | Post visibility default. Disabled when "Use preferences from server" is on. |
| CheckBox | Mark content sensitive by default | (none) | Disabled when server prefs are used. |
| PopUpButton | Expand media, {value} | (none) | Media display behavior. Disabled when server prefs are used. |
| CheckBox | Always expand content warnings | (none) | Disabled when server prefs are used. |

### App Preferences Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | App Preferences | (none) | Section header |
| Button | App Icon, {current} | (none) | Choose app icon. Label includes current selection. |
| PopUpButton | Appearance, {value} | (none) | System/Light/Dark theme |
| Button | Notifications | (none) | Push notification settings |
| PopUpButton | Status word, {value} | (none) | Terminology: Post/Toot/etc. |
| CheckBox | Show boost and favorite counts | (none) | value="1" = on |
| CheckBox | Require double tap to reblog | (none) | Safety feature |
| CheckBox | Require double tap to favorite | (none) | Safety feature |
| CheckBox | Open links in default browser | (none) | value="0" = uses in-app browser |
| CheckBox | Open links in other apps when available | (none) | Universal link handling |
| PopUpButton | Autoplay GIFs, {value} | (none) | Always/Wi-Fi/Never |
| PopUpButton | Autoplay videos, {value} | (none) | Always/Wi-Fi/Never |
| PopUpButton | Animate avatars, {value} | (none) | Everywhere/Never/etc. |
| CheckBox | Animate custom emoji | (none) | value="1" = on |
| CheckBox | Animate profile headers | (none) | value="1" = on |
| PopUpButton | Home timeline position on startup, {value} | (none) | Remember position/Newest |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Server prefs enabled | "Use preferences from server" value="1", server pref controls disabled | Default state |
| Server prefs disabled | "Use preferences from server" value="0", server pref controls enabled | User can override visibility, media, CW settings |

## Quirks

- No accessibility identifiers on any element — all must be located by label.
- PopUpButton labels include both the setting name and current value (e.g., "Appearance, System").
- Several controls are conditionally disabled based on "Use preferences from server" toggle.
- The screen is scrollable — bottom preferences (animations, timeline position) require scrolling down.
