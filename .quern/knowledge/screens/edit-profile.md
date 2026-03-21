---
screen: "edit-profile"
status: documented

identify_by:
  - "SFSafariViewController showing server settings page"

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Edit Profile" element_type="button"'

leads_to:
  - screen: "(previous screen)"
    action: "tap X close button in SFSafariViewController (top left, ~x:25 y:73)"

preconditions:
  - "logged in"

tags: [settings, web-view]
---

# Edit Profile

Opens the server's profile editing page in an SFSafariViewController. This is a web view, not a native screen.

## Behavior

- **Mastodon**: Shows the OAuth confirmation alert first (see [[alerts/oauth-confirmation]]), then opens the Mastodon web settings.
- **GoToSocial**: Opens the GoToSocial Settings page directly (no OAuth prompt). Shows the GtS login page where the user must authenticate.

## Key Elements

The web view content is not accessible via quern's UI tree — only the Application element is visible. The close button (X) is in the top left of the SFSafariViewController chrome.

## Quirks

- Not automatable — web view content is opaque to accessibility tools.
- The close button must be tapped by coordinates (~x:25 y:73).
- On GoToSocial, the user must log in to the web settings page separately from the app login.
