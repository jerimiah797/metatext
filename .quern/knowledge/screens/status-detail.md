---
screen: "status-detail"
status: documented

landmarks:
  - { element: "Button", identifier: "status.reply" }
  - { element: "Button", identifier: "status.reblog" }
  - { element: "Button", identifier: "status.favorite" }
  - { element: "Button", identifier: "status.share" }
  - { element: "Button", identifier: "status.menu" }

identify_by:
  - { element: "Button", identifier: "status.reply" }
  - { element: "Button", identifier: "status.reblog" }
  - { element: "Button", identifier: "status.favorite" }
  - { element: "Button", identifier: "status.share" }
  - { element: "Button", identifier: "status.menu" }

reachable_from:
  - screen: "[[screens/timelines]]"
    action: "tap a post cell"
  - screen: "[[screens/notifications]]"
    action: "tap a mention notification cell"

leads_to:
  - screen: "[[screens/profile]]"
    action: 'tap_element identifier="status.avatar" element_type="button"'
  - screen: "[[screens/profile]]"
    action: 'tap_element identifier="status.name" element_type="button"'
  - screen: "[[screens/compose]]"
    action: 'tap_element identifier="status.reply" element_type="button"'
  - screen: "[[screens/boosts-list]]"
    action: 'tap_element label_prefix="Boost" element_type="button"'
    condition: "label like '2 Boosts' — tap the count button, not the action button"
  - screen: "[[screens/favorites-list]]"
    action: 'tap_element label_prefix="Favorite" element_type="button"'
    condition: "label like '1 Favorite' — tap the count button, not the action button"
  - screen: "[[screens/status-menu]]"
    action: 'tap_element identifier="status.menu" element_type="button"'
  - screen: "[[screens/timelines]]"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [detail]
---

# Status Detail

Full view of a single post with expanded content, engagement counts, and action buttons. Shows reply thread context when available.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Back | `BackButton` | Returns to previous screen |
| Button | Show more for all | (none) | Top right, expands all CW-hidden content |
| Button | Avatar: {name} | `status.avatar` | Author's avatar, navigates to profile |
| Button | {name}, @handle@instance | `status.name` | Author name/handle, navigates to profile |
| StaticText | (post content) | (none) | Multiple StaticText elements for post body. value contains the text, label is empty. Custom actions include Link actions. |
| StaticText | {date} at {time} | (none) | Full timestamp |
| Image | {visibility} | `network` | Visibility icon (Public, Unlisted, Followers-only, etc.) |
| Button | {N} Boosts | (none) | Boost count, tappable to see who boosted |
| Button | {N} Favorite(s) | (none) | Favorite count, tappable to see who favorited |
| Button | Reply | `status.reply` | Reply action |
| Button | Boost | `status.reblog` | Boost action |
| Button | Favorite | `status.favorite` | Favorite action |
| Button | Share | `status.share` | System share sheet |
| Button | More | `status.menu` | Context menu (edit, delete, bookmark, pin, report, etc.) |
| GenericElement | In progress | (none) | Loading indicator for thread context, value="1" when loading |
| Button | Compose Post | `main.new-status` | Global FAB |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Loaded | Post content and action buttons visible | Normal state |
| Loading context | "In progress" GenericElement visible | Loading reply thread |
| With thread | Additional post cells below/above the main post | Thread context loaded |
| Edited | "Edited" label visible near timestamp | Post has been edited |

## Dynamic Content

The main post is shown in expanded form with full timestamps and visibility info. Below the post, a thread of replies may load. Above the post, parent posts in the thread may be shown.

Boost and favorite count buttons have dynamic labels (e.g., "2 Boosts", "1 Favorite"). These are separate from the action buttons which have fixed labels ("Boost", "Favorite").

## Quirks

- Post content is split across multiple `StaticText` elements with empty labels — the actual text is in the `value` field.
- The boost/favorite count buttons share similar labels with the action buttons. Count buttons have number prefixes (e.g., "2 Boosts") while action buttons are just "Boost"/"Favorite". Use `label_prefix` with a number to target count buttons.
- The "Show more for all" button only appears when there are CW-hidden posts in the thread.
