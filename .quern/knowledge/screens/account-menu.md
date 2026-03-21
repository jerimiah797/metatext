---
screen: "account-menu"
status: documented

identify_by:
  - { element: "Button", label: "close" }
  - { element: "Button", label: "My Profile" }
  - { element: "Button", label: "Preferences" }

reachable_from:
  - screen: "any screen with Account Menu button"
    action: 'tap_element label="Account Menu" element_type="button"'

leads_to:
  - screen: "[[screens/my-profile]]"
    action: 'tap_element label="My Profile" element_type="button"'
  - screen: "[[screens/edit-profile]]"
    action: 'tap_element label="Edit Profile" element_type="button"'
  - screen: "[[screens/account-settings]]"
    action: 'tap_element label="Account Settings" element_type="button"'
  - screen: "[[screens/accounts]]"
    action: 'tap_element label="Accounts" element_type="button"'
  - screen: "[[screens/lists]]"
    action: 'tap_element label="Lists" element_type="button"'
  - screen: "[[screens/favorites]]"
    action: 'tap_element label="Favorites" element_type="button"'
  - screen: "[[screens/bookmarks]]"
    action: 'tap_element label="Bookmarks" element_type="button"'
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'
  - screen: "[[screens/about]]"
    action: 'tap_element label="About This App" element_type="button"'

preconditions:
  - "logged in"

tags: [navigation, menu]
---

# Account Menu

Side menu / drawer showing account info and navigation to profile, settings, lists, and preferences.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | close | (none) | Top left, dismisses the menu |
| StaticText | (username) | (none) | Shows display name of current account |
| StaticText | (@handle@instance) | (none) | Shows full fediverse handle |
| Button | My Profile | (none) | View own profile |
| Button | Edit Profile | (none) | Edit profile fields |
| Button | Account Settings | (none) | Server-side account settings |
| Button | Accounts | (none) | Account switcher / manage accounts |
| Button | Lists | (none) | View/manage lists |
| Button | Favorites | (none) | View favorited posts |
| Button | Bookmarks | (none) | View bookmarked posts |
| Button | Preferences | (none) | App preferences (local settings) |
| Button | About This App | (none) | App info / credits |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Open | "close" button and menu items visible | Menu is displayed |

## Quirks

- None of the menu buttons have accessibility identifiers — all must be located by label.
- The close button label is lowercase "close" (not "Close").
- Account info at top is dynamic — shows the currently logged-in account's name and handle.
