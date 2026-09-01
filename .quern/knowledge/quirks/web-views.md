---
quirk: "web-views"
affects:
  - "[[screens/oauth-web]]"
  - "[[screens/instance-picker]]"
  - "[[screens/add-account]]"
  - "[[screens/account-settings]]"
  - "[[screens/edit-profile]]"
devices: []
severity: blocking
workaround: true
tags: [web-view, accessibility, automation-limit]
---

# Web View Content Is Invisible to the Accessibility Tree

Metatext has four web-backed surfaces. On all of them the *content* is opaque to
`get_ui_tree` / `get_screen_summary` — the container may appear, but nothing
inside it does. Automation inside a web view means coordinates, and coordinates
here are unusually fragile because the content is served by a third party and
can change without an app release.

None of these web views is first-party. Metatext does not control the HTML on
any of them, so there is nothing to add test identifiers to.

## The four surfaces

| Surface | Loads | Process | Reachable from |
|---|---|---|---|
| OAuth login | The instance's own OAuth page (varies per server) | **Out of process** — `ASWebAuthenticationSession` | [[screens/add-account]] → Log in |
| Instance picker | `https://joinmastodon.org/communities` | In process — `WKWebView` | [[screens/add-account]] → Get started |
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
  Metatext.

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
2. Use `take_screenshot` to see what is actually rendered, then coordinate-tap
   with `tap`. `take_annotated_screenshot` will not help — there are no
   accessibility frames inside the web view to annotate.
3. For the out-of-process surfaces, dismiss rather than drive. `account-settings`
   and `edit-profile` both record the close-button coordinates
   (`~x:25 y:73`); prefer those over trying to complete a task inside Safari.
4. Treat OAuth as manual. [[screens/oauth-web]] documents this: credential entry
   cannot be automated, so tests needing an authenticated session should restore
   a saved app-state checkpoint instead of signing in. Capturing that checkpoint
   requires `include_keychain: true`, because the auth token lives in the
   simulator keychain rather than the app container.

## Affected Devices

All. This is a platform property of `WKWebView` and the out-of-process web
surfaces, not a Metatext bug and not device- or OS-specific.

## Note for Quern development

Metatext is a useful test target for the hybrid-app automation work precisely
because none of these surfaces is first-party — it exercises the cases that
shipping an agent inside the web bundle cannot reach. The instance picker is the
most tractable of the four: in-process, a stable third-party URL, and no
authentication required to reach it.
