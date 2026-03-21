---
quirk: "compose-toolbar-accessibility"
severity: bug
screens:
  - "[[screens/compose]]"
---

# Compose Toolbar Buttons Not Accessible

The bottom toolbar on the Compose screen (poll, attach/visibility, CW, emoji, character count) has no accessibility labels or identifiers on its buttons. The toolbar `Group` element (`identifier: "Toolbar"`) is visible but its children are not exposed in the accessibility tree.

This is abnormal — every other screen in the app has reasonable accessibility on interactive elements. This is believed to be a bug in Metatext, not a framework limitation.

## Impact

- Agents cannot tap toolbar buttons by label or identifier
- Must use coordinate-based taps as a workaround
- Coordinates differ between server types (GoToSocial shows paperclip, Mastodon shows globe icon)

## Workaround

Use `tap` with approximate coordinates. See [[screens/compose]] for coordinate tables per server type.

## Status

Under investigation.
