---
app_name: "Metatext"
bundle_id: "org.arctian.metatext"
url_scheme: ""
universal_link_domain: ""
---

# Metatext

Mastodon/Fediverse client for iOS. Supports Mastodon and GoToSocial instances.

## Entry Points

| Method | Command | Lands On |
|---|---|---|
| Cold launch (logged out) | `launch_app bundle_id="org.arctian.metatext"` | [[screens/add-account]] |
| Cold launch (logged in) | `launch_app bundle_id="org.arctian.metatext"` | [[screens/timelines]] |

## Global Navigation

4-tab bar at bottom of screen. Tabs are `RadioButton` elements.

| Tab | Label | Identifier | Screen |
|---|---|---|---|
| 1 | Timelines | `tab.timelines` | [[screens/timelines]] |
| 2 | Explore | `tab.explore` | [[screens/explore]] |
| 3 | Notifications | `tab.notifications` | [[screens/notifications]] |
| 4 | Messages | `tab.messages` | [[screens/messages]] |

To switch tabs: `tap_element label="{Tab Label}" element_type="radioButton"`

## Global Elements

| Element | Type | Identifier | Notes |
|---|---|---|---|
| Account Menu | Button | `account-menu` | Top left on primary screens. Opens account switcher/settings. |
| Compose Post | Button | `main.new-status` | Floating action button, bottom right. Opens compose screen. |

## Test Accounts

| Account | Instance | Notes |
|---|---|---|
| the_moth | social.arctian.org | Primary test account, logged in on iPhone 17 Pro sim |
| arctian_test01 | social.arctian.org | Secondary test account |
