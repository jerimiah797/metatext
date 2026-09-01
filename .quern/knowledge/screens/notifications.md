---
screen: "notifications"
status: documented

landmarks:
  - { element: "TabGroup", identifier: "notifications.segment-control" }
  - { element: "RadioButton", identifier: "tab.notifications", selected: true }

identify_by:
  - { element: "TabGroup", identifier: "notifications.segment-control" }
  - { element: "RadioButton", identifier: "tab.notifications", value: "1" }

reachable_from:
  - screen: "any tab"
    action: 'tap_element label="Notifications" element_type="radioButton"'

leads_to:
  - screen: "[[screens/status-detail]]"
    action: "tap a mention notification cell"
  - screen: "[[screens/profile]]"
    action: "custom action: View profile (on favorite/follow notifications)"
  - screen: "[[screens/compose]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Account Menu" element_type="button"'

preconditions:
  - "logged in"

tags: [primary, tab]
---

# Notifications

Shows notifications for the logged-in account: mentions, favorites, boosts, follows, polls.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| TabGroup | (none) | `notifications.segment-control` | Segment control, likely All/Mentions filter |
| Button | Account Menu | `account-menu` | Global element |
| Button | Compose Post | `main.new-status` | Global FAB |

### Notification Cell Types

All notification cells are `GenericElement` with no identifier. Types differ by custom actions:

| Notification Type | Label Pattern | Custom Actions |
|---|---|---|
| Mention | `"username, @mention post text..., date"` | Reply, Boost, Favorite, Share, View author's profile, Copy text, Bookmark, Pin on profile, Report, Link actions |
| Favorite | `", username favorited your status, post text..., date"` | View profile |
| Boost | `", username boosted your status, post text..., date"` | View profile |
| Follow | `", username followed you, @handle, date"` | View profile |
| Generic (Mastodon) | `", Notification from username, post text..., date"` | View profile. **Mastodon only** — used for some notification types not mapped to specific categories. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Populated | Notification cells visible | Normal state |
| Empty | No notification cells | No notifications received |
| Loading | ActivityIndicator | During refresh |

## Dynamic Content

Scrollable list of notification items. Each shows the notification type, the acting user, and relevant post content. Tapping a mention goes to status detail; tapping a favorite/follow goes to the user's profile.

## Quirks

- Notification cells have no identifier — must locate by label content.
- Favorite/follow/boost notifications have a leading comma in their label (e.g., `", the_moth favorited your status..."`).
- **Mastodon link preview cards**: On Mastodon, notification labels may include link card metadata appended as `Link, {title}, {domain}`. These are not present on GoToSocial.
- **"Notification from" format**: Mastodon may use a generic `", Notification from {user}, ..."` format for notification types that don't have a specific label pattern (e.g., poll results, status updates).
