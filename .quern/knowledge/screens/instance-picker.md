---
screen: "instance-picker"
status: documented

landmarks: []
# TODO: needs a live screen. There is no reliable landmark available from source:
#   - the nav title is bound to the remote page's <title>
#     (webView.publisher(for: \.title) -> navigationItem.title), so it is
#     joinmastodon.org's copy, not Metatext's, and can change without a release;
#   - InstancePickerViewController sets no accessibilityIdentifier anywhere;
#   - the only stable native control is a system .done bar button, whose "Done"
#     label is locale-dependent and shared with other modals.
# Visit the screen, run get_ui_tree, and author from what the modal actually exposes.

reachable_from:
  - screen: "[[screens/add-account]]"
    action: 'tap_element identifier="add-identity.get-started" element_type="button"'

leads_to:
  - screen: "[[screens/add-account]]"
    action: "dismiss the modal — the picker returns the chosen instance URL to the URL field"

preconditions: []

tags: [onboarding, web-view]
---

# Instance Picker

Modally presented `WKWebView` loading `https://joinmastodon.org/servers`, so
a new user can browse Fediverse servers before choosing one. Presented inside a
`UINavigationController` from the "Get started" button on [[screens/add-account]].

Picking a community from the page hands the instance URL back to the add-account
screen, which fills it into `add-identity.url-field`.

## Key Elements

The navigation chrome is native and reachable. Everything below it is web
content and is **not** in the accessibility tree — see [[quirks/web-views]].

| Element Type | Label | Identifier | Notes |
|---|---|---|---|
| NavigationBar | *(the web page's title)* | (none) | Bound to `webView.title` — joinmastodon.org's copy, not Metatext's. Do not use as a landmark |
| Button | Done | (none) | System `.done` bar button; dismisses the modal |
| Button | *(chevrons)* | (none) | Back/forward web navigation; `title: nil`, image-only, no identifier |
| WebView | — | (none) | `joinmastodon.org/servers`; opaque to `get_ui_tree`, readable via the Web Inspector in a debug build — see [[quirks/web-views]] |

## States

| State | How to Recognize | Notes |
|---|---|---|
| Loading | Native nav bar present, blank content area | Third-party page load; can be slow or fail offline |
| Loaded | Screenshot shows the community list | Only visible via `take_screenshot` — not in the UI tree |
| Load failed | Blank or error content under the nav bar | No network, or joinmastodon.org unreachable |

## Dynamic Content

The community list is served by joinmastodon.org and changes without a Metatext
release. Do not assert on specific server names, positions, or coordinates —
this is third-party content on someone else's deployment schedule.

## Quirks

- See [[quirks/web-views]]. In-process `WKWebView`, so the frame is discoverable
  and coordinate taps land correctly — this is the most tractable of Metatext's
  four web surfaces.
- Reaching it requires no account or network auth, which makes it a convenient
  fixture for exercising web-view handling.

## Web content

Debug builds set `isInspectable = true` on this web view, so the page's own DOM
is available rather than only what accessibility exposes. Measured against
`joinmastodon.org/servers`:

| | elements | time |
|---|---|---|
| Web Inspector | 6, including the icon-only `Toggle menu` button | 15ms |
| Accessibility hit-test | 4, text only | ~830ms |

Page coordinates are viewport-relative; a single hit-test anchors them. The
offset here was `(0, 100)` — the web view starts below the nav bar.

The page is third-party and changes without an app release: it moved from
`/communities` to `/servers` between KB revisions. Prefer structural selectors
(`h1`, `button[aria-label]`) over text that the site can reword.

