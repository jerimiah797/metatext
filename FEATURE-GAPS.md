# Metatext Feature Gaps

Analysis of Mastodon 4.x and GoToSocial features not yet supported in this fork.
Last updated: 2026-02-17.

## Critical / High Priority

| Feature | Since | Notes |
|---|---|---|
| **Server-side filters v2** | Mastodon 4.0 | Still on v1 API; `Status.filtered` field absent — posts aren't filtered |
| **Hashtag following** | Mastodon 4.0 | No follow/unfollow tags, no followed tags timeline management |
| **Status translation** | Mastodon 4.0 | No translate endpoint at all |
| **Local-only post visibility** | GoToSocial/Glitch | No `local_only` visibility in compose or display |
| **Interaction policies** | GoToSocial 0.17+ | `interactionPolicy` on statuses completely ignored |

## Medium Priority

| Feature | Since | Notes |
|---|---|---|
| **Instance v2 API** | Mastodon 4.0 | Character limits, media limits, poll limits all undetected |
| **Grouped notifications** | Mastodon 4.3 | Still using v1 flat list |
| **Notification policies/requests** | Mastodon 4.3 | No filtered notifications inbox |
| **Quote posts** | Mastodon 4.4/4.5 | Silently ignored |
| **Markdown compose** | GoToSocial | `content_type` param not sent |
| **Max 6 media attachments** | GoToSocial | Hardcoded at 4 |

## Low Priority

| Feature | Since | Notes |
|---|---|---|
| **Trending statuses/links** | Mastodon 4.x | Only trending tags implemented |
| **Conversation mark-as-unread** | Mastodon 4.2 | No `POST /api/v1/conversations/:id/unread` |
| **`Relationship.requestedBy`** | Mastodon 4.1 | Pending follow requests toward you not shown |
| **Push subscription policy** | Mastodon 4.1 | `policy` field not modeled |
| **Grouped notifications v2** | Mastodon 4.3 | Server-side grouping not used |

## Fixed in This Fork

| Feature | Notes |
|---|---|
| GoToSocial settings URLs | `/user/settings` vs Mastodon's `/settings/...` |
| GoToSocial trends | Skip `/trends` API call for GTS instances |
| Hybrid search | Federated search no longer cancels local results |
| **Status editing** | `PUT /api/v1/statuses/:id`, "Edited" label, `editedAt` persisted in DB |
| **`update` notification type** | Handled in `NotificationPreferencesView` exhaustive switch |
| **Push `notificationId` is `Int`** | GoToSocial alphanumeric IDs now decoded as `String` |
