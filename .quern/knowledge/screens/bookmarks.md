---
screen: "bookmarks"
status: documented

landmarks:
  - { element: "Heading", label: "Bookmarks" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Bookmarks" element_type="button"'

leads_to:
  - screen: "[[screens/status-detail]]"
    action: "tap a post cell"
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [list]
---

# Bookmarks

List of posts the user has bookmarked. Standard post list layout.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Bookmarks | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to previous screen |
| Group | Empty list | (none) | Shown when no bookmarks exist |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Group label "Empty list" | No bookmarked posts |
| Populated | Post cells (GenericElement) visible | Has bookmarked posts |

## Quirks

- Same navigation pattern as Favorites — back goes to main timeline, not account menu.
