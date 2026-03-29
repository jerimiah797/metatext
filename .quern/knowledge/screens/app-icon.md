---
screen: "app-icon"
status: documented

identify_by:
  - { element: "Heading", label: "App Icon" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label_prefix="App Icon" element_type="button"'

leads_to:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'

preconditions:
  - "logged in"

tags: [settings]
---

# App Icon

Picker screen for choosing the app's home screen icon. Shows icon options as a grid of buttons.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | App Icon | (none) | Nav bar title |
| Button | Preferences | `BackButton` | Back to Preferences |
| Button | Classic | `app-icon.AppIconClassic` | Default icon option |
| Button | Rainbow | `app-icon.AppIconRainbow` | Rainbow variant |
| Button | Brutalist | `app-icon.AppIconBrutalist` | Brutalist variant |
| Button | Rainbow Brutalist | `app-icon.AppIconRainbowBrutalist` | Rainbow Brutalist variant |
| Button | Malow | `app-icon.AppIconMalow` | Malow variant |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Default | All icon buttons visible | Tapping an icon selects it |

## Quirks

- All icon buttons have `app-icon.*` identifiers using the raw enum value.
- Icon buttons are arranged in a grid, not a list.
- Tapping an icon immediately changes the app icon — no confirmation dialog.
