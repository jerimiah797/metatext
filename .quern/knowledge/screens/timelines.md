---
screen: "timelines"
status: documented

landmarks:
  - { element: "TabGroup", identifier: "timelines.segment-control" }
  - { element: "RadioButton", identifier: "tab.timelines", selected: true }

identify_by:
  - { element: "TabGroup", identifier: "timelines.segment-control" }
  - { element: "RadioButton", identifier: "tab.timelines", value: "1" }

reachable_from:
  - screen: "[[app]]"
    action: 'launch_app bundle_id="org.arctian.metatext"'
    condition: "logged in"
  - screen: "any tab"
    action: 'tap_element label="Timelines" element_type="radioButton"'

leads_to:
  - screen: "[[screens/compose]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Account Menu" element_type="button"'
  - screen: "[[screens/status-detail]]"
    action: "tap a post cell"
  - screen: "[[screens/profile]]"
    action: "custom action: View author's profile"
  - screen: "[[screens/explore]]"
    action: 'tap_element label="Explore" element_type="radioButton"'
  - screen: "[[screens/notifications]]"
    action: 'tap_element label="Notifications" element_type="radioButton"'
  - screen: "[[screens/messages]]"
    action: 'tap_element label="Messages" element_type="radioButton"'

preconditions:
  - "logged in"

tags: [primary, tab]
---

# Timelines

The main timeline screen showing posts from followed accounts and the wider fediverse. Contains a segment control to switch between timeline types (Home, Local, Federated).

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Account Menu | `account-menu` | Top left, opens account menu |
| TabGroup | (none) | `timelines.segment-control` | Segment control for Home/Local/Federated. On GoToSocial, children are hidden inside the TabGroup. On Mastodon, children appear as individual RadioButtons (Home, Local, Federated). |
| RadioButton | Home / Local / Federated | (none) | Segment control children. Only visible as separate elements on Mastodon accounts. |
| Button | Announcements | `timelines.announcements` | Top right. **Mastodon only** — not present on GoToSocial. |
| Button | New posts | (none) | Floating pill that appears when new posts are available. Tap to scroll to top and load. Has "Dismiss" custom action. |
| Button | Compose Post | `main.new-status` | FAB, bottom right |
| Group | (none) | `Metatext.TimelinesView` | Nav bar. Identifier only present on Mastodon accounts. |
| GenericElement | (post content) | (none) | Each post is a GenericElement with the full post text as its label |

### Post Cell Custom Actions

Each post cell (`GenericElement`) exposes these custom actions:
- **Reply** — opens compose in reply mode
- **Boost** — boosts the post
- **Favorite** — favorites the post
- **Share** — system share sheet
- **View author's profile** — navigates to author's profile
- **View booster's profile** — only present on boosted posts
- **Copy text** — copies post text
- **Bookmark** — bookmarks the post
- **Pin on profile** — pins to own profile (only on own posts)
- **Report** — reports the post
- **Link: ...** — one action per link/hashtag/mention in the post

## States

| State | How to Recognize | Notes |
|---|---|---|
| Populated | GenericElement post cells visible | Normal state with posts loaded |
| New posts available | "New posts" button visible | Tap to load new posts and scroll to top |
| Empty | No post cells | Rare — would indicate no followed accounts or server issue |
| Loading | ActivityIndicator visible | Brief, during initial load or refresh |

## Dynamic Content

The timeline is a scrollable list of posts. Each post shows:
- Author name and avatar
- Booster name (if boosted)
- Post text with inline links, hashtags, mentions
- Timestamp
- Engagement counts (replies, boosts, favorites)

Tapping a post navigates to [[screens/status-detail]].

## Quirks

- Post cells have no accessibility identifier — they must be located by their label (full post text) or position.
- **Server-dependent segment control behavior**: On GoToSocial, segment control children (Home/Local/Federated) are hidden inside the TabGroup. On Mastodon, they appear as individual RadioButton elements with no identifiers.
- **Announcements button** (`timelines.announcements`) only appears when connected to a Mastodon instance.
- **Nav bar identifier** (`Metatext.TimelinesView`) only present on Mastodon accounts.
