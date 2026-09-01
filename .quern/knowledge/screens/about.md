---
screen: "about"
status: documented

landmarks:
  - { element: "Heading", label: "About" }
  - { element: "Heading", label: "Made by Metabolist" }

identify_by:
  - { element: "Heading", label: "About" }
  - { element: "Heading", label: "Made by Metabolist" }

reachable_from:
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="About This App" element_type="button"'

leads_to:
  - screen: "[[screens/acknowledgments]]"
    action: 'tap_element label="Acknowledgments" element_type="button"'
  - screen: "(previous screen)"
    action: 'tap_element label="Back" element_type="button"'

preconditions:
  - "logged in"

tags: [info]
---

# About

App information screen showing version, credits, and external links.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | About | (none) | Nav bar title |
| Button | Back | `BackButton` | Returns to previous screen |
| StaticText | Metatext | (none) | App name |
| StaticText | 1.7.1 (2) | (none) | Version string (marketing version + build number) |
| Heading | Made by Metabolist | (none) | Credits section |
| Button | Official Account | (none) | Opens Metabolist's Mastodon profile |
| Button | Website | (none) | Opens Metabolist website |
| Button | Source Code & Issue Tracker | (none) | Opens GitHub repo |
| Button | Translations | (none) | Opens translation platform |
| Button | Rate the app | (none) | Opens App Store review |
| Button | Acknowledgments | (none) | Opens acknowledgments/licenses screen |

## Quirks

- All link buttons open external URLs (Safari/in-app browser) except Acknowledgments which navigates within the app.
- No identifiers on any elements.
