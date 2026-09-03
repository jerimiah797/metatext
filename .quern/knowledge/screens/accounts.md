---
screen: "accounts"
status: documented

landmarks:
  - { element: "Group", identifier: "Accounts" }
  - { element: "StaticText", label: "Add" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Accounts" element_type="button"'

leads_to:
  - screen: "[[screens/add-account]]"
    action: 'tap_element label="Add" element_type="staticText"'
  - screen: "(switches active account)"
    action: "tap an account row"
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [settings, accounts]
---

# Accounts

Account switcher and manager. Shows all logged-in accounts and allows adding new ones.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Accounts` | Nav bar with identifier |
| Heading | Accounts | (none) | Nav bar title and section header (appears twice) |
| Button | Back | `BackButton` | Returns to previous screen |
| Button | Edit | (none) | Top right, enables delete/reorder mode |
| StaticText | Add | (none) | Add new account. Note: this is a StaticText, not a Button. |
| StaticText | {name}, @{handle}@{instance} | (none) | Account row. Has "Log out" custom action. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Single account | One account row | Only one account logged in |
| Multi-account | Multiple account rows | Multiple accounts available |
| Edit mode | "Done" replaces "Edit" | Can delete/reorder accounts |

## Dynamic Content

Each account row is a `StaticText` (not Button) showing the display name and full handle. Tapping switches to that account. Each row has a "Log out" custom action.

## Quirks

- "Add" is a `StaticText` element, not a `Button` — tap by label works but element_type should be "staticText".
- Account rows are also `StaticText`, not buttons or cells.
- Both accounts (arctian_test01 and the_moth) are on `social.arctian.org` (GoToSocial).
- The "Log out" action is a custom action on the account row, not a separate button.
