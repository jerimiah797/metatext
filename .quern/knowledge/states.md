---
purpose: Defines the meaningful app states that affect navigation, available features, and screen behavior.
---

# App States

## Authentication

| State | How to Detect | How to Enter | How to Exit |
|---|---|---|---|
| Logged out | No tab bar visible; add-account screen shown | Account Menu → Accounts → remove all accounts (or fresh install) | Add an account via the add-account screen |
| Logged in | Tab bar visible (Timelines, Explore, Notifications, Messages) | Launch with existing account, or add account | Remove account or log out |
| Multi-account | Multiple accounts in Account Menu → Accounts | Add a second account | Remove extra accounts |

## Server Type

The connected server type is the most impactful state variable. It determines which features are available.

| State | How to Detect | How to Enter | How to Exit |
|---|---|---|---|
| Mastodon | Check instance info on Explore tab; full feature set available | Log in to a Mastodon instance | Switch to a different account |
| GoToSocial | Check instance info on Explore tab; some features missing (lists, polls, etc.) | Log in to a GoToSocial instance | Switch to a different account |
| Other | Instance info shows non-Mastodon/GtS server | Log in to a Pleroma/Akkoma/etc. instance | Switch to a different account |

## Onboarding

No dedicated onboarding/FTUE flow. First launch shows the add-account screen directly.

## Subscription

None — Metatext is fully free with no premium tier.
