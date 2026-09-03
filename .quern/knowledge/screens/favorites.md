---
screen: "favorites"
status: documented

landmarks:
  - { element: "Heading", label: "Favorites" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Favorites" element_type="button"'

leads_to:
  - screen: "[[screens/status-detail]]"
    action: "tap a post cell"
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [list]
---

# Favorites

List of posts the user has favorited. Standard post list layout.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Favorites | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to previous screen |
| Group | Empty list | (none) | Shown when no favorites exist |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Group label "Empty list" | No favorited posts |
| Populated | Post cells (GenericElement) visible | Has favorited posts |

## Quirks

- Back button goes to the main timeline, not the account menu (the account menu closes when navigating to sub-screens).
