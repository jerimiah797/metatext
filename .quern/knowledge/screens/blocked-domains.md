---
screen: "blocked-domains"
status: documented

identify_by:
  - { element: "Group", identifier: "Blocked Domains", role_description: "Nav bar" }
  - { element: "Heading", label: "Blocked Domains" }

reachable_from:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Blocked Domains" element_type="button"'

leads_to:
  - screen: "[[screens/preferences]]"
    action: 'tap_element label="Preferences" element_type="button"'

preconditions:
  - "logged in"

tags: [settings, moderation]
---

# Blocked Domains

List of domains the current account has blocked. Unlike Muted/Blocked Users, this screen has a nav bar identifier and back goes to Preferences.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Blocked Domains` | Nav bar with identifier |
| Heading | Blocked Domains | (none) | Nav bar title |
| Button | Preferences | `BackButton` | Back to Preferences |
| Button | Edit | (none) | Top right, enables delete mode |
| GenericElement | (domain) | (none) | Blocked domain row. Label may be empty, value contains data. |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | No GenericElement rows | No blocked domains |
| Has entries | GenericElement rows visible | Has blocked domains |
| Edit mode | "Done" replaces "Edit" | Can delete entries |

## Quirks

- Unlike Muted/Blocked Users, back button returns to Preferences (not the timeline).
- Has an Edit button (Muted/Blocked Users do not).
- Nav bar has an identifier (`"Blocked Domains"`) unlike the other moderation screens.
- Domain row elements may have empty labels — the domain data appears in the value field.
