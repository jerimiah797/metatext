---
screen: "explore"
status: documented

landmarks:
  - { element: "Group", identifier: "Explore" }
  - { element: "TextField", identifier: "explore.search-field" }
  - { element: "RadioButton", identifier: "tab.explore", selected: true }

reachable_from:
  - screen: "any tab"
    action: 'tap_element label="Explore" element_type="radioButton"'

leads_to:
  - screen: "[[screens/search-results]]"
    action: 'tap_element identifier="explore.search-field" element_type="textField"'
    condition: "after typing a search query"
  - screen: "[[screens/compose]]"
    action: 'tap_element label="Compose Post" element_type="button"'
  - screen: "[[screens/account-menu]]"
    action: 'tap_element label="Account Menu" element_type="button"'

preconditions:
  - "logged in"

tags: [primary, tab]
---

# Explore

Search and instance discovery screen. Shows the current instance info and a search field.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | (none) | `Explore` | Nav bar, role_description="Nav bar" |
| TextField | (none) | `explore.search-field` | Search field, placeholder value "Search" |
| StaticText | Trending Now | (none) | **Mastodon only** — section header for trending hashtags |
| GenericElement | #{hashtag}, {N} people talking, {N} recent uses | (none) | **Mastodon only** — trending hashtag row. help="View posts associated with trend". Tapping navigates to hashtag timeline. |
| StaticText | Instance | (none) | Section header for instance info |
| GenericElement | {instance}, {instance} | (none) | Instance info cell showing instance name and description |
| Button | Account Menu | `account-menu` | Global element |
| Button | Compose Post | `main.new-status` | Global FAB |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Default | "Instance" section visible, search field empty | Shows current instance info |
| Search active | Keyboard visible, search field focused | After tapping search field |

## Dynamic Content

**On Mastodon**: Shows a "Trending Now" section with trending hashtags, each displaying the hashtag name, number of people talking, and recent uses count. Tapping a trending hashtag navigates to that hashtag's timeline. Below trending, shows instance info.

**On GoToSocial**: No trending section — only shows instance info.

The instance info cell shows the server name and description for the account's home instance. This content varies by which account is logged in.

## Quirks

- The instance info cell has no identifier — it uses the instance domain as its label.
- **Trending section is Mastodon-only** — GoToSocial doesn't support the trending API, so the section is absent entirely.
- Trending hashtag rows have no identifier — located by label pattern `"#{hashtag}, {N} people talking, {N} recent uses"`.
