---
screen: "list-detail"
status: stub

identify_by: []

reachable_from:
  - screen: "[[screens/lists]]"
    action: "tap a list row"

leads_to:
  - screen: "[[screens/status-detail]]"
    action: "tap a post cell"
  - screen: "[[screens/lists]]"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"
  - "has at least one list"

tags: [list, mastodon-feature]
---

# List Detail

<!-- Not fully visited — requires creating a list with accounts first. -->
<!-- Expected to show a timeline of posts from accounts in the selected list, similar to the main timeline but filtered to list members. -->
<!-- Mastodon feature — may not work on GoToSocial. -->
