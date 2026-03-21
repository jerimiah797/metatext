---
screen: "oauth-web"
status: documented

identify_by:
  - "ASWebAuthenticationSession web view"

reachable_from:
  - screen: "[[screens/add-account]]"
    action: 'tap_element identifier="add-identity.log-in" element_type="button"'
    condition: "after entering instance URL and tapping Continue on OAuth alert"

leads_to:
  - screen: "[[screens/timelines]]"
    action: "complete OAuth authorization in web view"
  - screen: "[[screens/add-account]]"
    action: "cancel or close the web view"

preconditions: []

tags: [auth, web-view]
---

# OAuth Web View

ASWebAuthenticationSession web view for OAuth2 login. Shows the instance's login page where the user enters credentials and authorizes the app.

## Flow

1. User enters credentials on the instance's login page
2. User authorizes Metatext to access their account
3. Web view redirects back to the app with an OAuth token
4. App creates the account and navigates to the Timelines screen

## Key Elements

Web view content is not accessible via quern's UI tree — cannot be automated.

## Quirks

- Preceded by the OAuth confirmation alert (see [[alerts/oauth-confirmation]]).
- Not automatable — user must manually enter credentials.
- After successful auth, the app switches to the new account automatically.
