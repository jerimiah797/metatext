# Bug Fix: Deferred Deletion in Delete & Re-draft

## Summary

Fixed a critical bug where the "Delete & re-draft" feature was prematurely deleting posts even when the user cancelled the operation. The root cause was a JSON decoding conflict between explicit `CodingKeys` and the decoder's automatic snake_case conversion strategy.

## The Issue

When implementing a deferred deletion feature for "Delete & re-draft", the following behavior was observed:

1. User triggers "Delete & re-draft" on a post
2. Compose editor opens with text pre-populated
3. **Bug**: Original post is immediately deleted, even if user cancels
4. **Expected**: Original post should only be deleted after successfully posting the modified version

The feature was designed to:
- Fetch the post source non-destructively via `GET /api/v1/statuses/:id/source`
- Store the original post ID in `pendingDeleteId`
- Only delete the original after the new post succeeds

However, the original post was being deleted immediately, indicating the non-destructive fetch was failing and falling back to the old destructive path.

## Debugging Process

### Phase 1: Initial Investigation with Quern MCP

Used the Quern MCP debug server to monitor the app during testing:

1. **Set up proxy monitoring**:
   - Configured macOS system proxy to route iOS Simulator traffic through mitmproxy
   - Installed Quern's CA certificate on the simulator
   - Rebooted simulator to pick up proxy settings

2. **Created test post**: "Redraft test 3 - proxy monitoring active"

3. **Triggered Delete & re-draft** and captured the smoking gun in proxy logs:
   ```
   GET /api/v1/statuses/:id/source → 200 OK
   DELETE /api/v1/statuses/:id → 200 OK (26ms later!)
   ```

**Key Discovery**: The source fetch was returning 200 OK at the HTTP level, but the DELETE still fired immediately. This ruled out a server-side issue and pointed to a **client-side decode error** triggering the `.catch` fallback.

### Phase 2: Analyzing the Response

Retrieved the actual response body from the proxy:
```json
{
  "id": "...",
  "text": "Redraft test 3 - proxy monitoring active",
  "spoiler_text": "",
  "content_type": "text/plain"
}
```

The response was valid and contained the expected fields with snake_case keys (`spoiler_text`).

### Phase 3: Code Analysis

Examined `StatusSourceEndpoint.swift` and found:

```swift
public struct StatusSource: Decodable {
    public let id: Status.Id
    public let text: String
    public let spoilerText: String

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case spoilerText = "spoiler_text"  // ⚠️ Manual snake_case mapping
    }
}
```

Cross-referenced with `MastodonDecoder.swift`:

```swift
public final class MastodonDecoder: JSONDecoder {
    public init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase  // ⚠️ Automatic conversion!
    }
}
```

**Root Cause Identified**: The decoder was configured to automatically convert snake_case → camelCase, but `StatusSource` had explicit `CodingKeys` that also tried to map `spoiler_text`. This created a conflict:

1. Decoder converts JSON key `spoiler_text` → `spoilerText`
2. `CodingKeys` looks for raw key `"spoiler_text"`
3. Key no longer exists (already converted)
4. `DecodingError.keyNotFound` thrown
5. `.catch` block triggers destructive `deleteAndRedraft()` fallback

### Phase 4: Pattern Analysis

Checked other model types in the codebase (e.g., `Status.swift`) and confirmed they **do NOT** use explicit `CodingKeys` — they rely entirely on the decoder's automatic conversion. `StatusSource` was an outlier.

## The Fix

**Solution**: Remove the `CodingKeys` enum from `StatusSource.swift` to match the pattern used throughout the codebase.

```swift
public struct StatusSource: Decodable {
    public let id: Status.Id
    public let text: String
    public let spoilerText: String
    // ✅ Removed CodingKeys enum - decoder handles conversion automatically
}
```

### Additional Changes

Switched debug logging from `print()` to `os_log()` for better observability:

```swift
import os.log

// Before:
print("[Redraft] Source fetch succeeded")

// After:
os_log("[Redraft] Source fetch succeeded, text length: %d", source.text.count)
```

**Files Modified**:
- `MastodonAPI/Sources/MastodonAPI/Endpoints/StatusSourceEndpoint.swift` - Removed `CodingKeys`
- `ViewModels/Sources/ViewModels/View Models/StatusViewModel.swift` - Added `os_log`
- `ViewModels/Sources/ViewModels/View Models/CompositionViewModel.swift` - Added `os_log`
- `ViewModels/Sources/ViewModels/View Models/NewStatusViewModel.swift` - Added `os_log`
- `ServiceLayer/Sources/ServiceLayer/Services/StatusService.swift` - Added `os_log`

## Testing & Verification

### Test 1: Cancel Flow ✅ PASSED
1. Created test post "Redraft test 4 - CodingKeys fix applied"
2. Triggered "Delete & re-draft"
3. Proxy confirmed: `GET /source` returned 200, **NO DELETE fired**
4. Cancelled compose editor
5. Verified post still exists on Local timeline at 32s

### Test 2: Post Flow ✅ PASSED
1. Created test post "Redraft test 5 - testing post flow (original should be deleted)"
2. Triggered "Delete & re-draft"
3. Modified text to "Redraft test 5 MODIFIED - original should now be deleted!"
4. Posted successfully
5. Verified timeline shows:
   - ✅ New modified post appears
   - ✅ Original post is deleted

### Proxy Verification

Complete API flow captured by Quern proxy:

```
06:21:27 - POST /api/v1/statuses → 200 OK
           Body: "Redraft test 5 - testing post flow (original should be deleted)"
           (Created original, ID: 01KHFZC43110D21BYDFRCYK6KP)

06:27:21 - GET /api/v1/statuses/01KHFZC43110D21BYDFRCYK6KP/source → 200 OK
           ✅ Non-destructive fetch succeeds

06:28:18 - POST /api/v1/statuses → 200 OK
           Body: "Redraft test 5 MODIFIED - original should now be deleted!"
           (Created modified post)

06:28:18 - DELETE /api/v1/statuses/01KHFZC43110D21BYDFRCYK6KP → 200 OK
           ✅ Deferred delete fires ~26ms after POST succeeds
```

## How Quern MCP Helped

The Quern MCP debug server was instrumental in diagnosing and verifying the fix:

### 1. Network Proxy (mitmproxy)
- **Captured HTTP traffic** between app and server
- **Revealed the smoking gun**: GET /source returned 200 OK but DELETE still fired
- **Inspected actual response bodies** to confirm server was sending valid JSON
- **Verified the fix** by confirming the sequence: GET → POST → DELETE (not GET → DELETE)
- **Provided timing data**: DELETE fired 26ms after POST, confirming proper sequencing

### 2. Log Capture (oslog/syslog)
- Attempted to use for `os_log` output (though logs didn't appear due to configuration)
- Proxy data was sufficient for verification in this case

### 3. Device Management
- Provided tools to manage simulator state
- Boot, screenshot, and UI interaction capabilities
- Element inspection via accessibility tree

### 4. Key Benefits
- **No Xcode required**: Tested entirely through MCP without opening Xcode
- **API-level visibility**: Saw exactly what requests were sent/received
- **Real-time monitoring**: Watched the bug occur live in the proxy logs
- **Efficient debugging**: Proxy data provided definitive proof of both the bug and the fix

## Key Takeaways

1. **Be careful with CodingKeys when using `.convertFromSnakeCase`**: They can conflict and cause silent decode failures
2. **Follow codebase patterns**: Other models didn't use explicit `CodingKeys` — `StatusSource` shouldn't have either
3. **Proxy monitoring is invaluable**: HTTP-level visibility revealed the issue immediately
4. **Silent failures in `.catch` blocks**: The error was swallowed and triggered a fallback, making it hard to debug without network monitoring
5. **Use `os_log` over `print()`**: Makes logs available to system tools like Quern

## Related Files

### Implementation Files
- `ViewModels/Sources/ViewModels/View Models/StatusViewModel.swift:260` - `deleteAndRedraft()` method
- `ServiceLayer/Sources/ServiceLayer/Services/StatusService.swift:146` - `fetchForRedraft()` method
- `ViewModels/Sources/ViewModels/View Models/NewStatusViewModel.swift:187` - `performDeferredDeleteIfNeeded()`
- `ViewModels/Sources/ViewModels/View Models/CompositionViewModel.swift:67` - Compose initialization with redraft

### Bug Fix File
- `MastodonAPI/Sources/MastodonAPI/Endpoints/StatusSourceEndpoint.swift:8` - Removed conflicting `CodingKeys`

### Reference
- `Mastodon/Sources/Mastodon/Coding/MastodonDecoder.swift:9` - Global `.convertFromSnakeCase` strategy
- `Mastodon/Sources/Mastodon/Entities/Status.swift` - Example model without `CodingKeys`

---

**Date**: February 15, 2026
**Status**: ✅ Fixed and Verified
**Testing**: Both cancel and post flows passing
