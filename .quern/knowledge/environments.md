---
purpose: Documents the server environment types that affect app behavior.
---

# Environments

Metatext connects to any Mastodon-compatible Fediverse server. The server type is the primary environment variable — it determines which API features are available.

## Mastodon (full)

- **API**: Full Mastodon API support
- **Features**: All app features available — lists, polls, scheduled posts, filters v1/v2, DMs, full notification types, trending, suggestions, announcements
- **Test instance**: `social.coop` (Mastodon)
- **Test account**: logged in on iPhone 17 Pro sim alongside GoToSocial accounts
- **UI differences vs GoToSocial**:
  - Timelines: Announcements button (`timelines.announcements`), segment control children visible as individual RadioButtons, nav bar has `Metatext.TimelinesView` identifier
  - Explore: "Trending Now" section with trending hashtag rows (absent on GtS)
  - Compose: Globe (visibility picker) in toolbar instead of paperclip (attach), character limit 500 vs 5000
  - Notifications: "Notification from {user}" generic format, link preview cards in notification labels
  - Messages: Functional DM conversations (empty on GtS test accounts)
  - Preferences: Structurally identical, only default values differ

## GoToSocial

- **API**: Subset of Mastodon API. Actively developing toward parity but missing some endpoints.
- **Known limitations**:
  - No lists support
  - No polls
  - No scheduled posts
  - No trending/suggestions
  - Limited filter support (v1 only as of early 2026)
  - DMs may behave differently
  - Notification types may be a subset
- **Test instance**: `social.arctian.org` (GoToSocial)
- **Test accounts**: `the_moth@social.arctian.org`, `arctian_test01@social.arctian.org`

## Other (untested)

- Pleroma, Akkoma, Misskey-derivatives, etc.
- These implement varying subsets of the Mastodon API
- Not actively tested — behavior may be unpredictable

## How to Determine Server Type

The app discovers the server type at login via the instance API (`/api/v1/instance`). The server type affects which API calls the app makes and which features are shown. Server type is not directly visible in the UI — check the instance description on the Explore tab or inspect network traffic.

## Switching Environments

The app supports multiple accounts on different servers. To switch:
1. Open Account Menu → Accounts
2. Select a different account or add a new one

Each account is tied to its server — switching accounts effectively switches the server environment.
