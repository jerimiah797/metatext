---
screen: "lists"
status: documented

identify_by:
  - { element: "Group", identifier: "Lists", role_description: "Nav bar" }
  - { element: "Heading", label: "Lists" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Lists" element_type="button"'

leads_to:
  - screen: "[[screens/list-detail]]"
    action: "tap a list row"
    condition: "has existing lists"
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [list, mastodon-feature]
---

# Lists

Manage user-created lists. Lists allow grouping followed accounts into custom timelines.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Lists` | Nav bar with identifier |
| Heading | Lists | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to previous screen |
| Button | Edit | (none) | Top right, enables delete/reorder mode |
| TextField | (none) | `lists.new-list-title` | New list title input, placeholder "New List Title" |
| Button | Add | `lists.add` | Creates a new list. Disabled until title is entered. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Only text field and Add button visible, no list rows | No lists created |
| Has lists | List row buttons visible below the create section | Lists exist |
| Edit mode | "Done" replaces "Edit" | Can delete/reorder lists |

## Quirks

- **Mastodon feature**: Lists work on Mastodon but may fail or show empty on GoToSocial (GtS doesn't fully support the lists API).
- The "New List Title" text field has identifier `lists.new-list-title`.
- The Add button is disabled until text is entered in the title field.
