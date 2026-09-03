---
quirk: "web-views"
affects:
  - "[[screens/oauth-web]]"
  - "[[screens/instance-picker]]"
  - "[[screens/add-account]]"
  - "[[screens/account-settings]]"
  - "[[screens/edit-profile]]"
devices: []
severity: workaround-available
workaround: true
tags: [web-view, accessibility, web-inspector]
---

# Web View Content Needs a Route Other Than the Accessibility Tree

Metatext has four web-backed surfaces. On all of them the *content* is opaque to
`get_ui_tree` / `get_screen_summary` — the tree walk does not descend into a
`WKWebView`, and on the out-of-process surfaces the view is not even in the
app's hierarchy.

**That no longer means coordinates.** Two routes reach the content, and which
one applies is decided entirely by the in-process/out-of-process split below.

None of these web views is first-party: Metatext does not control the HTML on
any of them, so there is nothing to add test identifiers *to*. That is a
narrower limitation than it first appears — `isInspectable` is a property of the
`WKWebView` the app constructs, not of the content it loads, so Metatext can
opt its own web views in and then use the page's existing semantics.

## The four surfaces

| Surface | Loads | Process | Reachable from |
|---|---|---|---|
| OAuth login | The instance's own OAuth page (varies per server) | **Out of process** — `ASWebAuthenticationSession` | [[screens/add-account]] → Log in |
| Instance picker | `https://joinmastodon.org/servers` | In process — `WKWebView` | [[screens/add-account]] → Get started |
| "What is Mastodon?" video | `https://www.youtube.com/embed/IPSbNdBmWKE` | In process — `WKWebView` | Embedded on [[screens/add-account]] |
| Server settings pages | The instance's settings/profile pages | **Out of process** — `SFSafariViewController` | [[screens/account-settings]], [[screens/edit-profile]] |

The in-process versus out-of-process split matters more than it looks:

- **In-process `WKWebView`** renders inside Metatext's own window. The view is
  part of the app's hierarchy, so its *frame* is discoverable even though its
  contents are not. Coordinate taps land in the right place.
- **Out-of-process (`ASWebAuthenticationSession`, `SFSafariViewController`)**
  runs in a separate system process. The app's accessibility tree does not
  contain it at all. Even the container is not the app's to inspect, and the
  system chrome (Done/close button, address bar) belongs to Safari, not to
  Metatext. Metatext never constructs a `WKWebView` for these, so there is
  nothing to set `isInspectable` on and the Web Inspector route is closed.

## The two routes that do work

| Route | Reaches | Cost | Gives |
|---|---|---|---|
| **Web Inspector** | in-process `WKWebView` in a DEBUG build | ~15ms | tags, `id`, `aria-label`, `href`, geometry, JS evaluation |
| **Accessibility hit-test** | any web content the AX runtime exposes | ~1s | type and label, no identifiers |

**Prefer the Web Inspector.** Debug builds set `isInspectable = true` on both
in-process web views, so the instance picker returns its whole DOM in one round
trip. Measured on `joinmastodon.org/servers`: six elements in 15ms, including
the icon-only `Toggle menu` button — which has no text at all and is therefore
invisible to every screenshot- or accessibility-based approach.

Page geometry is viewport-relative. One accessibility hit-test on any element
anchors it to the screen; on the instance picker the offset was `(0, 100)`.

**Hit-testing is the fallback**, and the only route on a release build or an
out-of-process surface. `describe_point` reaches inside a `WKWebView` even
though the tree walk does not, so content is discoverable one point at a time —
measured on the same page as `Link "Mastodon"`, `Heading "Servers"` and the body
text. It cannot enumerate, and it cannot see anything without text.

## Symptoms

- `get_screen_summary` returns a nearly empty screen, or shows only native
  chrome (a nav bar, a Cancel button) with no body content.
- `tap_element` fails to find anything inside the web area, by label or by
  identifier, no matter how the element is described.
- On the out-of-process surfaces, the agent may not be able to tell which screen
  it is on at all, because none of the usual landmarks are present.

## Workaround

1. Detect the situation rather than fighting it. A screen summary with native
   chrome but no body content is the signal.
2. On an in-process surface in a debug build, read the DOM through the Web
   Inspector. This is the route to prefer and the only one that sees controls
   without text.
3. Otherwise fall back to hit-testing, and to coordinates only when that finds
   nothing. `take_annotated_screenshot` still helps here — it draws a coordinate
   grid automatically when a screen has no interactive elements, which is
   exactly this case.
4. For the out-of-process surfaces, dismiss rather than drive. `account-settings`
   and `edit-profile` both record the close-button coordinates
   (`~x:25 y:73`); prefer those over trying to complete a task inside Safari.
5. Treat OAuth as manual. [[screens/oauth-web]] documents this: credential entry
   cannot be automated, so tests needing an authenticated session should restore
   a saved app-state checkpoint instead of signing in. Capturing that checkpoint
   requires `include_keychain: true`, because the auth token lives in the
   simulator keychain rather than the app container.

## Affected Devices

All. This is a platform property of `WKWebView` and the out-of-process web
surfaces, not a Metatext bug and not device- or OS-specific. `isInspectable`
requires iOS 16.4 or later; below that a `WKWebView` is inspectable by default
and needs no opt-in.

## Note for Quern development

Metatext is a useful test target for the hybrid-app automation work precisely
because none of these surfaces is first-party — it exercises the cases that
shipping an agent inside the web bundle cannot reach. The instance picker is the
most tractable of the four: in-process, a stable third-party URL, and no
authentication required to reach it — and now the worked example of the Web
Inspector route against content nobody involved controls.
