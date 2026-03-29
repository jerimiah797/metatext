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
    action: 'tap_element identifier="preferences.filters"'
  - screen: "[[screens/notification-types]]"
    action: 'tap_element identifier="preferences.notification-types"'
  - screen: "[[screens/muted-users]]"
    action: 'tap_element identifier="preferences.muted-users"'
  - screen: "[[screens/blocked-users]]"
    action: 'tap_element identifier="preferences.blocked-users"'
  - screen: "[[screens/blocked-domains]]"
    action: 'tap_element identifier="preferences.blocked-domains"'
  - screen: "[[screens/app-icon]]"
    action: 'tap_element identifier="preferences.app-icon"'
  - screen: "[[screens/notification-prefs]]"
    action: 'tap_element identifier="preferences.notifications"'
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
| Button | Filters | `preferences.filters` | Manage content filters |
| Button | Notification Types | `preferences.notification-types` | Configure notification types |
| Button | Muted Users | `preferences.muted-users` | View/manage muted users |
| Button | Blocked Users | `preferences.blocked-users` | View/manage blocked users |
| Button | Blocked Domains | `preferences.blocked-domains` | View/manage blocked domains |
| CheckBox | Use preferences from server | `preferences.use-server-preferences` | value="1" = on. When on, server prefs are used and local overrides are disabled. |
| PopUpButton | Default visibility, {value} | `preferences.posting-default-visibility` | Post visibility default. Disabled when "Use preferences from server" is on. |
| CheckBox | Mark content sensitive by default | `preferences.posting-default-sensitive` | Disabled when server prefs are used. |
| PopUpButton | Expand media, {value} | `preferences.reading-expand-media` | Media display behavior. Disabled when server prefs are used. |
| CheckBox | Always expand content warnings | `preferences.reading-expand-spoilers` | Disabled when server prefs are used. |

### App Preferences Section

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | App Preferences | (none) | Section header |
| Button | App Icon, {current} | `preferences.app-icon` | Choose app icon. Label includes current selection. |
| PopUpButton | Appearance, {value} | `preferences.color-scheme` | System/Light/Dark theme |
| Button | Notifications | `preferences.notifications` | Push notification settings |
| PopUpButton | Status word, {value} | `preferences.status-word` | Terminology: Post/Toot/etc. |
| CheckBox | Show boost and favorite counts | `preferences.show-reblog-and-favorite-counts` | value="1" = on |
| CheckBox | Require double tap to reblog | `preferences.require-double-tap-to-reblog` | Safety feature |
| CheckBox | Require double tap to favorite | `preferences.require-double-tap-to-favorite` | Safety feature |
| CheckBox | Open links in default browser | `preferences.open-in-default-browser` | value="0" = uses in-app browser |
| CheckBox | Open links in other apps when available | `preferences.use-universal-links` | Universal link handling |
| CheckBox | Use new compose screen | `preferences.use-swiftui-compose` | SwiftUI compose toggle |
| PopUpButton | Autoplay GIFs, {value} | `preferences.autoplay-gifs` | Always/Wi-Fi/Never |
| PopUpButton | Autoplay videos, {value} | `preferences.autoplay-videos` | Always/Wi-Fi/Never |
| PopUpButton | Animate avatars, {value} | `preferences.animate-avatars` | Everywhere/Never/etc. |
| CheckBox | Animate custom emoji | `preferences.animate-custom-emojis` | value="1" = on |
| CheckBox | Animate profile headers | `preferences.animate-headers` | value="1" = on |
| PopUpButton | Home timeline position on startup, {value} | `preferences.home-timeline-position` | Remember position/Newest |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Server prefs enabled | "Use preferences from server" value="1", server pref controls disabled | Default state |
| Server prefs disabled | "Use preferences from server" value="0", server pref controls enabled | User can override visibility, media, CW settings |

## Quirks

- All elements have accessibility identifiers with `preferences.*` prefix.
- PopUpButton labels include both the setting name and current value (e.g., "Appearance, System").
- Several controls are conditionally disabled based on "Use preferences from server" toggle.
- The screen is scrollable — bottom preferences (animations, timeline position) require scrolling down.
