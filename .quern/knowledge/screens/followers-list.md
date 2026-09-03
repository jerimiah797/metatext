---
screen: "followers-list"
status: documented

landmarks:
  - { element: "Heading", label_contains: "Followers" }

reachable_from:
  - screen: "[[screens/profile]]"
    action: 'tap_element label_contains="Follower" element_type="button"'

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a user row"
  - screen: "[[screens/profile]]"
    action: 'tap_element identifier="BackButton" element_type="button"'

preconditions:
  - "logged in"

tags: [list, detail]
---

# Followers List

Shows the list of users who follow a given account. Same user card pattern as following/boosts/favorites lists.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | @{handle}'s Followers | (none) | Nav bar title, includes the account handle |
| Button | @{handle} | `BackButton` | Back to profile. Label is the account handle. |
| GenericElement | {name}, @{handle}, {bio} | (none) | User profile card |

## Quirks

- Heading uses "@handle's Followers" format.
- Back button label is the account handle, not "Back".
- No identifiers on user cards.
