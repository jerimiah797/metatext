---
screen: "boosts-list"
status: documented

identify_by:
  - "List of user profile cards (GenericElement with name, handle, bio) after tapping a boost count button"

reachable_from:
  - screen: "[[screens/status-detail]]"
    action: 'tap_element label_prefix="Boost" element_type="button"'
    condition: "tap the count button (e.g., '2 Boosts'), not the action button ('Boost')"

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a user row"
  - screen: "[[screens/status-detail]]"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [list, detail]
---

# Boosts List

Shows the list of users who boosted a specific post. Each user is shown as a profile card.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Back | `BackButton` | Returns to status detail |
| GenericElement | {name}, @{handle}, {bio} | (none) | User profile card. Shows display name, full handle, and bio text. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Populated | GenericElement user cards visible | Has boosters |
| Empty | No user cards | No boosts (shouldn't reach this screen if count is 0) |

## Quirks

- No nav bar title visible in the accessibility tree — the screen has no heading element.
- User cards are GenericElement, not buttons — tapping them navigates to the user's profile.
- No identifiers on any elements.
