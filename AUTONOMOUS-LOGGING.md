# Autonomous iOS Simulator Logging

This document explains the autonomous logging system built for Metatext to enable programmatic log capture without human intervention.

## Problem Statement

Traditional iOS logging approaches have limitations for autonomous debugging:
- **Xcode console**: Requires human to manually view and copy/paste logs
- **`os_log`/NSLog via unified logging**: Requires root privileges or special entitlements to read programmatically
- **`print()` to stdout**: Only captured when debugger is attached
- **Console.app**: Requires manual GUI interaction

**Goal**: Enable autonomous agents (like Quern) to programmatically capture NSLog output without requiring humans to manually extract logs from Xcode or Console.app.

## Solution: In-App File Redirection

### How It Works

NSLog writes to `stderr` (file descriptor 2). By redirecting stderr to a file we control, all NSLog output automatically goes to a file that can be read programmatically.

### Implementation

**File**: `System/AppDelegate.swift`

```swift
extension AppDelegate: UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        self.application = application

        #if DEBUG
        configureDebugLogging()
        #endif

        configureGlobalAppearance()
        return true
    }
}

private extension AppDelegate {
    func configureDebugLogging() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let logPath = documentsPath.appendingPathComponent("debug.log")

        // Redirect stderr (where NSLog writes) to our log file
        freopen(logPath.path.cString(using: .utf8), "a+", stderr)

        NSLog("[DEBUG-LOG] Logging redirected to: %@", logPath.path)
        NSLog("[DEBUG-LOG] Documents directory: %@", documentsPath.path)
    }
}
```

**Key Points:**
- `freopen()` redirects stderr to a file
- Mode `"a+"` appends to existing file (logs persist across app launches)
- Only compiled in DEBUG builds (`#if DEBUG`)
- First two log lines confirm redirection and show the path

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

# 3. Get the container path
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

# 7. Filter for specific events
grep "\[SEARCH-TRACE\].*scrolling: true" "$CONTAINER/Documents/debug.log" | wc -l
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

## Limitations

1. **DEBUG builds only**: Production builds don't include this (by design)
2. **Container path changes**: Must fetch fresh path after reinstall
3. **File grows unbounded**: Consider clearing old logs periodically
4. **stderr only**: Only captures NSLog, not os_log or print()

## Clearing Old Logs

To start fresh, delete the log file before launching:

```bash
rm -f "$CONTAINER/Documents/debug.log"
xcrun simctl launch 43B500A9-B34B-4E50-AB65-F9F0F3281E07 org.arctian.metatext
```

## Future Enhancements

Potential improvements to consider:

- **Log rotation**: Automatically archive old logs when file exceeds size limit
- **Structured logging**: Output JSON for easier parsing
- **Multiple log files**: Separate files per subsystem
- **Remote access**: Serve logs via local HTTP endpoint for remote debugging
- **Stdout capture**: Also redirect stdout to capture print() statements

## See Also

- `System/AppDelegate.swift` - Implementation
- `Data Sources/ExploreDataSource.swift` - Example usage
- `Data Sources/TableViewDataSource.swift` - Example usage
- `DB/Sources/DB/Content/ContentDatabase.swift` - Database logging
