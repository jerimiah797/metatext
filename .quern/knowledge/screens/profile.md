---
screen: "profile"
status: documented

identify_by:
  - { element: "Button", label_prefix: "Header image:" }
  - { element: "Button", label_prefix: "Avatar:" }
  - { element: "Heading", label: "@username" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="My Profile" element_type="button"'
    condition: "own profile"
  - screen: "[[screens/status-detail]]"
    action: 'tap_element identifier="status.avatar" element_type="button"'
  - screen: "[[screens/status-detail]]"
    action: 'tap_element identifier="status.name" element_type="button"'
  - screen: "[[screens/timelines]]"
    action: "custom action: View author's profile (on a post cell)"
  - screen: "[[screens/notifications]]"
    action: "custom action: View profile (on a notification cell)"

leads_to:
  - screen: "[[screens/following-list]]"
    action: 'tap_element label_prefix="Following" element_type="button"'
  - screen: "[[screens/followers-list]]"
    action: 'tap_element label_prefix="Follower" element_type="button"'
  - screen: "[[screens/status-detail]]"
    action: "tap a post cell"
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [detail]
---

# Profile

User profile screen showing header, avatar, display name, handle, bio, stats, and a tabbed list of posts.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Back | `BackButton` | Returns to previous screen |
| Heading | @{username} | (none) | Nav bar title showing handle |
| Button | Header image: {name} | (none) | Header/banner image. Disabled if no header set. |
| Button | Avatar: {name} | (none) | User avatar, tappable to view full size |
| StaticText | {display name} | (none) | Display name |
| GenericElement | @{handle}, {indicators} | (none) | Handle + account indicators (e.g., "Locked account") |
| StaticText | {N} Posts | (none) | Post count |
| StaticText | Joined {date} | (none) | Join date |
| Button | {N} Following | (none) | Following count, tappable |
| Button | {N} Follower(s) | (none) | Follower count, tappable |
| TabGroup | (none) | (none) | Segment control for Posts / Posts & Replies / Media |

### Post Cell Custom Actions (own profile)

When viewing your own profile, post cells have additional actions:
- **Mute conversation** — mute the thread
- **Delete** — delete the post
- **Delete & re-draft** — delete and open compose with the text pre-filled

### Post Cell Custom Actions (other user's profile)

Standard post actions: Reply, Boost, Favorite, Share, View author's profile, Copy text, Bookmark, Report

## States

| State | How to Recognize | Notes |
|---|---|---|
| Own profile | Post cells have "Delete" and "Delete & re-draft" actions | Viewing the logged-in user's profile |
| Other user | No delete actions on posts; may show Follow/Unfollow button | Viewing someone else's profile |
| Locked account | GenericElement label includes "Locked account" | Account requires follow approval |
| Has edited posts | Post cells with labels starting with ", Edited," | Posts that have been edited show "Edited" indicator |

## Dynamic Content

Below the profile header, a tabbed list shows the user's posts. The tab group likely has segments for:
- Posts (default)
- Posts & Replies
- Media

Each post cell is a `GenericElement` with the post content as its label.

## Quirks

- No accessibility identifiers on profile elements — all located by label.
- The TabGroup for post filtering has no identifier (unlike timelines and notifications segment controls).
- Edited posts have a leading comma and "Edited" in their label: `", Edited, username, post text..."`.
- The "Locked account" indicator appears inline in the handle GenericElement, not as a separate element.
