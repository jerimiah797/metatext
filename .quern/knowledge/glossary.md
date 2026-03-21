---
purpose: Domain-specific terms used in the app and this knowledge base.
---

# Glossary

| Term | Meaning | Where It Appears |
|---|---|---|
| Status | A post/toot on the Fediverse. The API object representing a single post. | API, codebase |
| Boost / Reblog | Sharing someone else's post. "reblog" in API, "boost" in UI. | Timeline, Status Detail |
| Favorite | Liking a post. "favourite" (British spelling) in the Mastodon API. | Timeline, Status Detail |
| Toot | Original Mastodon term for a post. User can choose "Post" or "Toot" in Preferences. | Preferences (status word) |
| CW | Content Warning — hides post content behind a spoiler toggle. | Compose toolbar, Status Detail |
| Fediverse | The federated network of Mastodon, GoToSocial, Pleroma, etc. servers. | General |
| Instance | A single Fediverse server (e.g., social.arctian.org). | Explore, Accounts |
| Handle | Full user address: @username@instance.domain | Profile, Accounts |
| GoToSocial (GtS) | Lightweight Fediverse server with subset of Mastodon API. | Environments |
| Mastodon | Most popular Fediverse server software, most complete API. | Environments |
| Filter (v1) | Simple keyword filter: matches a phrase and hides matching posts. Legacy format. | Filters screen |
| Filter (v2) | Enhanced filter with multiple keywords, expiration, Warn/Hide actions. Requires Mastodon 4.0+ or GtS 0.17+. | Filters screen |
| Visibility | Post audience: Public, Unlisted, Followers-only, or Direct (DM). | Compose, Status Detail, Preferences |
| Locked account | Account requiring manual approval of follow requests. | Profile |
| Redraft | Delete a post and reopen compose with its text — workaround for servers without edit. | Profile (own posts) |

## Knowledge Base Terms

These terms have specific meaning within this knowledge base:

| Term | Meaning |
|---|---|
| screen | A distinct UI state with its own document in `screens/`. Modals and sheets count as separate screens; transient popups and dialogs are alerts instead. |
| flow | An ordered sequence of actions across screens to achieve a goal. Includes setup (state prep), steps (actions + verifications), failure modes, teardown (cleanup), and shortcuts. |
| interceptor | An alert or coaching tip that appears mid-flow and must be dismissed before proceeding. Documented in flow failure modes tables. |
| deep link | A URL (custom scheme or universal link) that jumps directly to a screen, bypassing manual navigation. |
| alert | A transient dialog, popup, permission prompt, or coaching overlay that appears on top of a screen. Documented in `alerts/` when it can appear across multiple screens. |
| state | An app-wide mode (auth, subscription, onboarding, environment) that affects which screens are accessible and how they behave. Defined in `states.md`. |
| environment | A server backend the app connects to (production, staging). Defined in `environments.md`. |
| quirk | A non-obvious behavior that an agent wouldn't predict from the UI alone. |
| stub | A minimal screen file for a screen discovered as a navigation edge but not yet visited. Has `status: stub`. |
| identify_by | Elements an agent checks to confirm which screen it's on. Listed in reliability order. |
| precondition | App state that must be true before a screen or flow is reachable. References entries in `states.md`. |
