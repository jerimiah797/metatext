---
screen: "add-account"
status: documented

landmarks:
  - { element: "TextField", identifier: "add-identity.url-field" }
  - { element: "Button", identifier: "add-identity.log-in" }

identify_by:
  - { element: "TextField", identifier: "add-identity.url-field" }
  - { element: "Button", identifier: "add-identity.log-in" }

reachable_from:
  - screen: "[[screens/accounts]]"
    action: 'tap_element label="Add" element_type="staticText"'
  - screen: "[[app]]"
    action: 'launch_app bundle_id="org.arctian.metatext"'
    condition: "logged out (no accounts)"

leads_to:
  - screen: "[[screens/oauth-web]]"
    action: 'tap_element identifier="add-identity.log-in" element_type="button"'
    condition: "after entering instance URL"
  - screen: "[[screens/accounts]]"
    action: 'tap_element label="Accounts" element_type="button"'
    condition: "Back button"

preconditions: []

tags: [auth, onboarding]
---

# Add Account

Screen for adding a new Mastodon/Fediverse account. Prompts for instance URL, then launches OAuth web login.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Button | Accounts | `BackButton` | Back to accounts list (only when adding from multi-account) |
| StaticText | Enter the URL of the Mastodon instance... | (none) | Instruction text |
| TextField | Instance URL | `add-identity.url-field` | Text field for entering instance domain |
| Button | Log in | `add-identity.log-in` | Initiates OAuth flow after URL is entered |
| StaticText | What is Mastodon? | (none) | Informational section |
| Button | Get started | `add-identity.get-started` | Likely links to joinmastodon.org or similar onboarding |

## Flow

1. Enter instance URL in `add-identity.url-field` (e.g., "social.arctian.org" or "mastodon.social")
2. Tap "Log in" (`add-identity.log-in`)
3. Web OAuth2 view opens — user enters credentials in the browser
4. After authorization, redirects back to the app
5. App creates the account and switches to it

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | URL field shows placeholder "Instance URL" | Initial state |
| URL entered | URL field has text value | Ready to log in |
| First launch | No back button visible | App has no accounts yet |
| Adding account | Back button shows "Accounts" | Adding from existing session |

## Quirks

- The OAuth web view is a system SFSafariViewController or ASWebAuthenticationSession — not automatable via quern's tap/type tools. User must enter credentials manually.
- The URL field expects just the domain (e.g., "mastodon.social"), not a full URL with protocol.
