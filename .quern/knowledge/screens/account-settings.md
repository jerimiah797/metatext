---
screen: "account-settings"
status: documented

landmarks: []
# TODO: no machine-evaluable landmarks yet. Legacy note: SFSafariViewController showing server settings page
# Re-author from a live screen, or see the note in the body below.

identify_by:
  - "SFSafariViewController showing server settings page"

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Account Settings" element_type="button"'

leads_to:
  - screen: "(previous screen)"
    action: "tap X close button in SFSafariViewController (top left, ~x:25 y:73)"

preconditions:
  - "logged in"

tags: [settings, web-view]
---

# Account Settings

Opens the server's account settings page in an SFSafariViewController. This is a web view, not a native screen. Same behavior as [[screens/edit-profile]] — server-managed settings.

## Behavior

- **Mastodon**: Shows the OAuth confirmation alert first (see [[alerts/oauth-confirmation]]), then opens the Mastodon web settings.
- **GoToSocial**: Opens the GoToSocial Settings page directly.

## Key Elements

Web view content is not accessible via quern's UI tree.

## Quirks

- Not automatable — web view content is opaque to accessibility tools.
- Close button must be tapped by coordinates (~x:25 y:73).
