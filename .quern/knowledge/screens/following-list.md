---
screen: "following-list"
status: documented

identify_by:
  - { element: "Heading", label_contains: "Followed by" }

reachable_from:
  - screen: "[[screens/profile]]"
    action: 'tap_element label_contains="Following" element_type="button"'

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a user row"
  - screen: "[[screens/profile]]"
    action: 'tap_element identifier="BackButton" element_type="button"'

preconditions:
  - "logged in"

tags: [list, detail]
---

# Following List

Shows the list of users that a given account follows. Same user card pattern as boosts/favorites lists.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Followed by @{handle} | (none) | Nav bar title, includes the account handle |
| Button | @{handle} | `BackButton` | Back to profile. Label is the account handle. |
| GenericElement | {name}, @{handle}, {bio} | (none) | User profile card |

## Quirks

- Heading uses "Followed by @handle" format (not "Following").
- Back button label is the account handle (e.g., "@arctian_test01"), not "Back".
- No identifiers on user cards.
