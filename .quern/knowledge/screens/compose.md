---
screen: "compose"
status: documented

identify_by:
  - { element: "Button", identifier: "new-status.cancel" }
  - { element: "Button", identifier: "new-status.post" }
  - { element: "TextArea", identifier: "composition.text" }

reachable_from:
  - screen: "[[screens/timelines]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/notifications]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/messages]]"
    action: 'tap_element label="Compose Post" element_type="button"'

leads_to:
  - screen: "(previous screen)"
    action: 'tap_element label="Cancel" element_type="button"'
  - screen: "(previous screen)"
    action: 'tap_element label="Post" element_type="button"'
    condition: "Post button enabled (text entered)"

preconditions:
  - "logged in"

tags: [core-flow, modal]
---

# Compose

Modal screen for composing a new post. Presented as overFullScreen modal over the previous tab's content.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Cancel | `new-status.cancel` | Top left X button, dismisses compose |
| Button | Post | `new-status.post` | Top right, disabled until text is entered |
| Button | @handle@instance | (none) | Avatar button, top left below nav. help="Tap to post with a different account" |
| StaticText | What's on your mind? | (none) | Placeholder text, disappears when typing |
| TextArea | (none) | `composition.text` | Main text input area |
| Group | Toolbar | `Toolbar` | Bottom toolbar with compose options |

### Toolbar Buttons (from screenshot, left to right)

The toolbar children are **not exposed in the accessibility tree** — these must be tapped by coordinates if needed.

**On GoToSocial:**

| Icon | Purpose | Approximate X | Y |
|---|---|---|---|
| Bar chart | Add poll | ~67 | ~852 |
| Paperclip | Attach media | ~168 | ~852 |
| CW | Content warning toggle | ~290 | ~852 |
| Smiley | Emoji picker | ~395 | ~852 |
| 5000 | Character count remaining | ~503 | ~852 |

**On Mastodon:**

| Icon | Purpose | Approximate X | Y |
|---|---|---|---|
| Bar chart | Add poll | ~67 | ~852 |
| Globe | Visibility picker | ~178 | ~852 |
| CW | Content warning toggle | ~290 | ~852 |
| Smiley | Emoji picker | ~400 | ~852 |
| 500 | Character count remaining | ~510 | ~852 |

Note: Coordinates are approximate based on screenshot at 402pt width. The character count updates as text is entered. The toolbar differs by server type — GoToSocial shows attach media (paperclip) while Mastodon shows visibility picker (globe). Character limit also differs (5000 on GtS, 500 on Mastodon by default).

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Placeholder "What's on your mind?" visible, Post button disabled | Initial state |
| Has text | Placeholder gone, Post button enabled | Ready to post |
| Reply mode | Additional context shown (replying-to info) | When opened from Reply action on a post |
| Edit mode | Pre-filled with existing post text | When editing an existing post |

## Quirks

- **overFullScreen modal**: Compose is presented with `.overFullScreen` style, meaning the underlying tab view stays in the hierarchy. On slower devices (iPhone 11/A13), this can make the accessibility tree too dense for WDA to snapshot, especially over the Timelines tab. Works better over simpler screens (Explore, Notifications).
- **Toolbar not accessible**: The bottom toolbar's buttons (poll, attach, CW, emoji, character count) have no accessibility labels or identifiers. They can only be interacted with via coordinate taps.
- **Visibility picker**: On Mastodon, the second toolbar button is a globe icon for visibility. On GoToSocial, it's a paperclip for media attachment — visibility is controlled by server-side default preference only.
- **Character limit varies by server**: 500 on standard Mastodon, 5000 on GoToSocial. The count in the toolbar reflects the server's configured limit.
