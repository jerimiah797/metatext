# Autonomous iOS Simulator Logging

This document explains the autonomous logging system built for Metatext to enable programmatic log capture without human intervention.

## Problem Statement

Traditional iOS logging approaches have limitations for autonomous debugging:
- **Xcode console**: Requires human to manually view and copy/paste logs
- **`os_log` via unified logging**: Requires root privileges or special entitlements to read programmatically
- **`print()` to stdout**: Only captured when debugger is attached (without special setup)
- **Console.app**: Requires manual GUI interaction

**Goal**: Enable autonomous agents (like Quern) to programmatically capture app logs without requiring humans to manually extract logs from Xcode or Console.app.

## Solution: In-App File Redirection

### How It Works

`NSLog` writes to `stderr` (file descriptor 2) and `print()` writes to `stdout` (file descriptor 1). By redirecting these file descriptors to a file we control, all output automatically goes to a file that can be read programmatically.

### Implementation

**File**: `System/AppDelegate.swift`

```swift
private extension AppDelegate {
    func configureDebugLogging() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logPath = documentsPath.appendingPathComponent("debug.log")

        // Redirect both stdout (print) and stderr (NSLog) to our log file
        freopen(logPath.path.cString(using: .utf8), "a+", stdout)
        freopen(logPath.path.cString(using: .utf8), "a+", stderr)

        // Disable stdout buffering so print() flushes immediately (like stderr/NSLog)
        setbuf(stdout, nil)

        NSLog("[DEBUG-LOG] Logging redirected to: %@", logPath.path)
    }
}
```

**Key Points:**
- `freopen()` redirects both stdout and stderr to the same file
- `setbuf(stdout, nil)` is **required** for print() — without it, stdout is fully-buffered when writing to a file and output won't appear until the buffer fills (~8KB) or the process exits
- stderr (used by NSLog) is always unbuffered, so it works without `setbuf`
- Mode `"a+"` appends to existing file (logs persist across app launches)
- Only compiled in DEBUG builds (`#if DEBUG`)

## NSLog vs print() — Which to Use

**Use `NSLog` for instrumentation. It is significantly more valuable for autonomous debugging.**

### NSLog output format:
```
2026-02-16 19:03:48.040 Metatext[4652:877441] [VIEWMODEL-TRACE] sections emitted (items: 82)
```

### print() output format:
```
[VIEWMODEL-TRACE] sections emitted (items: 82)
```

### Why NSLog wins for autonomous debugging

| Feature | NSLog | print() |
|---------|-------|---------|
| Millisecond timestamp | ✅ automatic | ❌ must format manually |
| Process ID | ✅ automatic | ❌ must add manually |
| Thread ID | ✅ automatic | ❌ must add manually |
| Buffering issues | ✅ never (stderr is unbuffered) | ⚠️ requires `setbuf(stdout, nil)` |
| Correlate with proxy logs | ✅ timestamps match HTTP flows | ❌ no timestamp |
| Correlate with UI interactions | ✅ timestamps match Quern events | ❌ no timestamp |

The automatic timestamps from NSLog allow you to correlate app-side events with network flows captured by the proxy and UI interactions recorded by Quern — all in a shared time reference. This is essential for root cause analysis.

### Using printf-style formatting with NSLog

NSLog uses `%@`, `%d`, `%f` format specifiers (not Swift string interpolation):

```swift
NSLog("[VIEWMODEL-TRACE] sections: %d, items: %d, hash: %ld", sections.count, totalItems, sections.hashValue)
```

## Programmatic Access

### Finding the App Container

Each app installation has a unique container directory. To find it:

```bash
CONTAINER=$(xcrun simctl get_app_container <UDID> <BUNDLE_ID> data)
```

**Example:**
```bash
CONTAINER=$(xcrun simctl get_app_container \
    43B500A9-B34B-4E50-AB65-F9F0F3281E07 \
    org.arctian.metatext \
    data)
echo $CONTAINER
# Output: /Users/jham/Library/Developer/CoreSimulator/Devices/43B500A9.../Application/7E1B9151.../
```

**Important:** The container path changes when you reinstall the app! Always fetch it fresh.

### Reading the Logs

Once you have the container path, the log file is at `Documents/debug.log`:

```bash
cat "$CONTAINER/Documents/debug.log"
```

### Real-Time Monitoring

Use `tail -f` to watch logs in real-time as the app runs:

```bash
tail -f "$CONTAINER/Documents/debug.log"
```

### Filtering Logs

Use grep to filter for specific trace markers:

```bash
# Find all search-related logs
grep "\[SEARCH-TRACE\]" "$CONTAINER/Documents/debug.log"

# Find all explore-related logs
grep "\[EXPLORE-TRACE\]" "$CONTAINER/Documents/debug.log"

# Find database observation logs
grep "\[DB-TRACE\]" "$CONTAINER/Documents/debug.log"

# Count occurrences
grep -c "\[SEARCH-TRACE\]" "$CONTAINER/Documents/debug.log"

# Correlate with a time window (e.g. everything between 19:03:47 and 19:03:49)
grep "19:03:4[789]" "$CONTAINER/Documents/debug.log"
```

## Complete Workflow Example

Here's a complete workflow for autonomous log capture and analysis:

```bash
# 1. Build and install the app
xcodebuild -scheme Metatext -configuration Debug \
    -destination 'platform=iOS Simulator,id=43B500A9-B34B-4E50-AB65-F9F0F3281E07' \
    -derivedDataPath ./DerivedData build

xcrun simctl install 43B500A9-B34B-4E50-AB65-F9F0F3281E07 \
    "./DerivedData/Build/Products/Debug-iphonesimulator/Metatext.app"

# 2. Launch the app
xcrun simctl launch 43B500A9-B34B-4E50-AB65-F9F0F3281E07 org.arctian.metatext

# 3. Get the container path (do this AFTER launch — container may change on reinstall)
CONTAINER=$(xcrun simctl get_app_container \
    43B500A9-B34B-4E50-AB65-F9F0F3281E07 \
    org.arctian.metatext \
    data)

# 4. Wait for app to initialize
sleep 2

# 5. Interact with the app (using Quern or other automation)
# ... perform test actions ...

# 6. Read and analyze logs
cat "$CONTAINER/Documents/debug.log"

# 7. Cross-reference with proxy: find app logs within 500ms of a specific HTTP request
# (Quern captures proxy timestamps; match them to NSLog timestamps here)
grep "19:03:48" "$CONTAINER/Documents/debug.log"
```

## Log Markers

We use consistent markers to identify different subsystems:

| Marker | Source | Purpose |
|--------|--------|---------|
| `[DEBUG-LOG]` | AppDelegate | Log redirection confirmation |
| `[EXPLORE-TRACE]` | ExploreDataSource, ExploreViewModel | Trending tags and instance info |
| `[SEARCH-TRACE]` | TableViewDataSource | Search results and table updates |
| `[DB-TRACE]` | ContentDatabase | Database observations and queries |
| `[VIEWMODEL-TRACE]` | CollectionItemsViewModel | Publisher chain and data flow |

## Advantages

1. **No human intervention**: Logs are automatically captured to a file
2. **Programmatic access**: Bash scripts and tools can read/analyze logs directly
3. **Works without debugger**: App can be launched via simctl, no Xcode needed
4. **Persistent**: Logs survive across multiple app runs (append mode)
5. **Standard tooling**: Use grep, awk, sed, etc. for analysis
6. **Real-time monitoring**: tail -f for live log streaming
7. **Time-correlated**: NSLog timestamps enable cross-referencing with proxy traffic and UI events

## Limitations

1. **DEBUG builds only**: Production builds don't include this (by design)
2. **Container path changes**: Must fetch fresh path after reinstall
3. **File grows unbounded**: Consider clearing old logs periodically
4. **Simulator only**: Physical devices require different tooling (no simctl get_app_container)

## Clearing Old Logs

To start fresh, delete the log file before launching:

```bash
CONTAINER=$(xcrun simctl get_app_container 43B500A9-B34B-4E50-AB65-F9F0F3281E07 org.arctian.metatext data)
rm -f "$CONTAINER/Documents/debug.log"
xcrun simctl launch 43B500A9-B34B-4E50-AB65-F9F0F3281E07 org.arctian.metatext
```

## Future Enhancements

Potential improvements to consider:

- **Log rotation**: Automatically archive old logs when file exceeds size limit
- **Structured logging**: Output JSON for easier parsing
- **Physical device support**: Alternative capture mechanism for real devices

## See Also

- `System/AppDelegate.swift` - Implementation
