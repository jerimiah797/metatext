---
screen: "status-menu"
status: documented

landmarks:
  - { element: "Button", label: "Dismiss context menu" }
  - { element: "Button", label: "Bookmark" }

reachable_from:
  - screen: "[[screens/status-detail]]"
    action: 'tap_element identifier="status.menu" element_type="button"'

leads_to:
  - screen: "[[screens/status-detail]]"
    action: 'tap_element label="Dismiss context menu" element_type="button"'

preconditions:
  - "logged in"

tags: [overlay, context-menu]
---

# Status Menu (More)

Context menu that appears when tapping the "More" button on a status detail screen. Shows as a popover/context menu overlay.

## Key Elements (other user's post)

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Bookmark | (none) | Bookmark the post |
| Button | Pin on profile | (none) | Pin to own profile |
| Button | Report | (none) | Report the post |
| Button | Dismiss context menu | (none) | Full-screen dismiss button behind the menu |

## Key Elements (own post)

When viewing your own post, additional options appear (based on custom actions seen on profile screen):

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Bookmark | (none) | Bookmark the post |
| Button | Mute conversation | (none) | Mute the thread |
| Button | Pin on profile | (none) | Pin to own profile |
| Button | Edit | (none) | Edit the post (if server supports editing) |
| Button | Delete | (none) | Delete the post |
| Button | Delete & re-draft | (none) | Delete and reopen in compose |
| Button | Dismiss context menu | (none) | Full-screen dismiss button |

## Quirks

- This is a context menu overlay, not a full screen. The "Dismiss context menu" button covers the entire screen behind the menu.
- No identifiers on any elements.
- Menu options differ based on whether the post is yours or someone else's.
- The menu appears as a popover anchored near the More button.
