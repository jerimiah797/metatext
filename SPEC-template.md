# Feature Spec Template

Copy this file to `SPEC-<feature-name>.md` and fill it in before starting implementation.

---

## Overview

_One paragraph describing the feature and why it's being added._

## API

| | |
|---|---|
| **Method** | `GET` / `POST` / `PUT` / `DELETE` |
| **Path** | `/api/v1/...` |
| **Auth required** | Yes / No |

### Request body
```json
{
  "field": "value"
}
```

### Response body
```json
{
  "field": "value"
}
```

### Server compatibility notes
- [ ] Mastodon — tested on version: ___
- [ ] GoToSocial — tested on version: ___
- Known quirks: _e.g. missing fields, typos, extra fields_

---

## Model layer (`Mastodon` package)

For each new or changed field on a `Mastodon` entity:

| Field | Type | JSON key | Default needed? |
|---|---|---|---|
| `exampleField` | `String?` | `example_field` | No / Yes — `@DecodableDefault` |

- [ ] Field added to entity struct
- [ ] Field included in `==` and `hash(into:)`
- [ ] `@DecodableDefault` added if the field may be absent from older servers

---

## DB layer (`DB` package)

> ⚠️ Every new model field that needs to persist requires ALL FOUR of these.

For each new field in `StatusRecord` (or other `*Record`):

| Step | Location | Done? |
|---|---|---|
| Add stored property | `StatusRecord.swift` | [ ] |
| Add `Columns` entry | `StatusRecord.swift` | [ ] |
| Assign in `init(status:)` | `StatusRecord.swift` | [ ] |
| Assign in `Status.init(record:)` | `Status+ Extensions.swift` | [ ] |
| Add column to migration | `ContentDatabase+Migration.swift` | [ ] |

Migration name convention: `"<next-version>-<short-description>"` (e.g. `"2.0.0-status-edited-at"`)

---

## Service layer

- [ ] New method(s) on `IdentityService`
- [ ] New method(s) on `StatusService` (if status-related)
- [ ] Publisher chain: request → insert into DB → return value

---

## ViewModel layer (`ViewModels` package)

- [ ] New computed property on `StatusViewModel` (or other view model)
- [ ] Wired through `CollectionItemEvent` if triggered from a cell action
- [ ] Wired through `RootViewModel` / `TableViewController` if it opens a new screen

---

## View layer

- [ ] UI changes described: _e.g. new label, disabled control, new button_
- [ ] Localization string added to `Localizable.strings`
- [ ] Accessibility label / hint updated if needed

---

## Test plan

- [ ] Happy path on Mastodon
- [ ] Happy path on GoToSocial
- [ ] Edge cases: _list them_
- [ ] DB migration verified on existing install (not just fresh)
