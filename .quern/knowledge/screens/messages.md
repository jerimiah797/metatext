---
screen: "messages"
status: documented

landmarks:
  - { element: "Heading", label: "Messages" }
  - { element: "RadioButton", identifier: "tab.messages", selected: true }

reachable_from:
  - screen: "any tab"
    action: 'tap_element label="Messages" element_type="radioButton"'

leads_to:
  - screen: "[[screens/compose]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Account Menu" element_type="button"'

preconditions:
  - "logged in"

tags: [primary, tab]
---

# Messages

Direct messages screen. Shows conversations with other users.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Heading | Messages | (none) | Nav bar title |
| Group | Empty list | (none) | Shown when no conversations exist |
| GenericElement | {sender}, @{mention} {preview}, {date} | (none) | Conversation row. No identifier. Label includes "Unread" if unread. |
| Button | Account Menu | `account-menu` | Global element |
| Button | Compose Post | `main.new-status` | Global FAB |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Empty | Group with label "Empty list" visible | No DM conversations |
| Populated | Conversation cells visible | Has DM threads |

## Dynamic Content

When populated, shows a list of DM conversation threads. Each row is a `GenericElement` showing:
- Sender display name
- @mention of a participant
- Message preview text
- Date

Unread conversations include "Unread" in the label (e.g., `"Alex, Unread, @jerimiah797 message text..., date"`). Tapping a conversation navigates to the conversation detail.

Note: Messages were empty on the GoToSocial test account but populated on the Mastodon account (social.coop).

## Quirks

- Conversation rows have no identifier — located by label.
- "Unread" indicator is embedded in the label, not a separate element.
