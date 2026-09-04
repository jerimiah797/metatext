---
screen: "account-settings"
status: documented

# The accessibility tree reports exactly one element here (the Application), so
# there is nothing native to identify this screen by. The web view is the
# identity: the URL comes from the Web Inspector's page listing, which costs one
# round trip and no probes.
landmarks:
  # Scoped to the hosting process: the app's own web views are connected at the
  # same time, and a page URL alone cannot say which of them is showing it.
  - { web_url_contains: "/settings", web_process: "com.apple.SafariViewService" }

# Measured 2026-09-03 against social.arctian.org (GoToSocial 0.22.1).
web_content:
  - host: "SFSafariViewController"
    process: "com.apple.SafariViewService"
    # Out of process: hosted by SafariViewService, NOT by org.arctian.metatext,
    # so this is what to pass as bundle_id. It needs no isInspectable from the
    # app -- that property only governs the app's own WKWebViews.
    reachable_by: [inspector, hit_test]
    url: "https://social.arctian.org/settings"
    anchor:
      # A hint, not a fact: confirmed by one probe before use, and ignored if it
      # no longer holds. Recorded because finding it otherwise costs a 17-probe
      # sweep -- the view carries its own chrome at both ends, none of which the
      # native tree can see, so geometry cannot guess the origin.
      origin: [0, 106]
      viewport: [402, 685]
      measured_on: "iPhone 16 Pro - iOS 18.6"

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

- Served in an out-of-process `SFSafariViewController`; contents are not in the app's accessibility tree — see [[quirks/web-views]].

- Not automatable — web view content is opaque to accessibility tools.
- Close button must be tapped by coordinates (~x:25 y:73).
