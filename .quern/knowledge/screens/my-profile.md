---
screen: "my-profile"
status: documented

landmarks: []
# TODO: no machine-evaluable landmarks yet. Legacy note: Same as [[screens/profile]] — this is just an alias for viewing your own profile
# Re-author from a live screen, or see the note in the body below.

identify_by:
  - "Same as [[screens/profile]] — this is just an alias for viewing your own profile"

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="My Profile" element_type="button"'

leads_to: []

preconditions:
  - "logged in"

tags: [alias]
---

# My Profile

This is the same screen as [[screens/profile]], viewed for the currently logged-in account. See [[screens/profile]] for full documentation.

The only difference is the entry point: Account Menu → My Profile. The screen behavior, elements, and states are identical to viewing any profile, with the additional "own post" custom actions (Delete, Delete & re-draft, Mute conversation) on post cells.
