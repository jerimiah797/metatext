---
screen: "acknowledgments"
status: documented

landmarks:
  - { element: "Heading", label: "Acknowledgments" }

reachable_from:
  - screen: "[[screens/about]]"
    action: 'tap_element label="Acknowledgments" element_type="button"'

leads_to:
  - screen: "[[screens/about]]"
    action: 'tap_element label="About" element_type="button"'

preconditions:
  - "logged in"

tags: [info]
---

# Acknowledgments

Scrollable list of third-party library licenses used in the app. Each library is a tappable Button (name) followed by a StaticText (full license text).

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Acknowledgments | (none) | Nav bar title |
| Button | About | `BackButton` | Back to About screen |
| Button | {library name} | (none) | Library name, tappable (likely opens project URL) |
| StaticText | {license text} | (none) | Full license text for the library |

## Libraries Listed

- BlurHash
- CombineExpectations
- GRDB
- SDWebImage
- SQLCipher

## Quirks

- Very long scrollable content — each license is the full MIT/BSD text.
- Library name buttons have no identifiers.
- Back button label is "About" (parent screen name).
