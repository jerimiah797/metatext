---
screen: "search-results"
status: documented

landmarks:
  - { element: "Group", label: "Search results" }
  - { element: "RadioButton", label: "All" }
  - { element: "RadioButton", label: "People" }

identify_by:
  - { element: "Group", label: "Search results" }
  - { element: "RadioButton", label: "All" }
  - { element: "RadioButton", label: "People" }

reachable_from:
  - screen: "[[screens/explore]]"
    action: 'tap_element identifier="explore.search-field" element_type="textField"'
    condition: "type a search query — results appear live"

leads_to:
  - screen: "[[screens/profile]]"
    action: "tap a People result"
  - screen: "[[screens/status-detail]]"
    action: "tap a Posts result"
  - screen: "[[screens/explore]]"
    action: 'tap_element label="Close" element_type="button"'

preconditions:
  - "logged in"

tags: [search]
---

# Search Results

Live search results shown on the Explore tab when text is entered in the search field. Results appear instantly as you type — no submit needed.

## Key Elements

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| Group | Search results | (none) | Container for results |
| Button | Close | (none) | Top right, dismisses search and returns to Explore |
| RadioButton | All | (none) | Filter tab — shows all result types. value="1" when selected. |
| RadioButton | People | (none) | Filter tab — shows only accounts |
| RadioButton | Posts | (none) | Filter tab — shows only statuses |
| RadioButton | Hashtags | (none) | Filter tab — shows only hashtags |

## Result Types

Results are shown in sections when "All" is selected:
- **People**: User profile cards (name, handle, bio)
- **Posts**: Post cells (same GenericElement format as timeline)
- **Hashtags**: Hashtag rows

## States

| State | How to Recognize | Notes |
|---|---|---|
| Results showing | "Search results" group visible, result items present | Live results for current query |
| No results | "Search results" group visible, no items | Query matched nothing |
| Filtered | One of People/Posts/Hashtags RadioButton has value="1" | Showing only one result type |

## Quirks

- Search is live — results appear as you type, no search button needed.
- Filter tabs (All/People/Posts/Hashtags) have no identifiers — use label.
- Individual result items may not appear in the accessibility tree even though they're visible on screen.
- The search field remains from the Explore screen (same `explore.search-field` identifier).
- Close button dismisses search, not the back button pattern used elsewhere.
