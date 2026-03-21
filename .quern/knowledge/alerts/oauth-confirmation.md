---
alert: "oauth-confirmation"
trigger: "Tapping 'Log in' on the add-account screen"
appears_on:
  - "[[screens/add-account]]"

identify_by:
  - { element: "StaticText", label_prefix: "\"Metatext\" Wants to Use" }
  - { element: "Button", label: "Continue" }
  - { element: "Button", label: "Cancel" }

suppression: "None — appears every time OAuth login is initiated"
---

# OAuth Sign-In Confirmation

System alert from `ASWebAuthenticationSession` asking the user to confirm they want to sign in via the instance's website.

## Text

> "Metatext" Wants to Use "{instance domain}" to Sign In
>
> This allows the app and website to share information about you.

## Actions

| Button | Effect | Default for Agent |
|---|---|---|
| Continue | Opens the OAuth web view for the instance | Yes |
| Cancel | Dismisses the alert, returns to add-account screen | No |

## Notes

- This is a system-level alert, not app UI — it comes from iOS's `ASWebAuthenticationSession`.
- The instance domain in the message is dynamic (e.g., "social.coop", "social.arctian.org").
- After tapping Continue, a web view opens for the user to enter credentials. This web view is not automatable via accessibility tools.
