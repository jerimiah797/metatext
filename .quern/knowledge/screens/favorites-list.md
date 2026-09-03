---
screen: "favorites-list"
status: documented

landmarks: []
# TODO: no machine-evaluable landmarks yet. Legacy note: List of user profile cards (GenericElement with name, handle, bio) after tapping a favorite count button
# Re-author from a live screen, or see the note in the body below.

reachable_from:
  - screen: "[[screens/status-detail]]"
    action: 'tap_element label_prefix="Favorite" element_type="button"'
    condition: "tap the count button (e.g., '1 Favorite'), not the action button ('Favorite')"

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a user row"
  - screen: "[[screens/status-detail]]"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [list, detail]
---

# Favorites List

Shows the list of users who favorited a specific post. Identical structure to [[screens/boosts-list]].

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Back | `BackButton` | Returns to status detail |
| GenericElement | {name}, @{handle}, {bio} | (none) | User profile card |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Populated | GenericElement user cards visible | Has users who favorited |

## Quirks

- No nav bar title — same as boosts list.
- No identifiers on any elements.
- Structurally identical to [[screens/boosts-list]].
