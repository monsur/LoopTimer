# Plan: Enable Live Activities for Loop Timer

## Status: Understanding Requirements

## Current Situation

Your app **already has Live Activity code implemented** in `LoopTimerWidgetExtension/LoopTimerLiveActivity.swift`, including:
- Dynamic Island UI (for iPhone 14 Pro+)
- Lock Screen UI
- Progress bar and elapsed/remaining time displays
- Integration with TimerViewModel

**What's Missing**: The `NSSupportsLiveActivities` key in Info.plist to enable the feature.

## Critical Issues Discovered

Through exploration, I've identified significant architectural challenges:

### 1. Timer Stops in Background
- Your timer uses `DispatchSourceTimer` which **suspends when iOS backgrounds the app**
- Live Activities will show **stale data** after ~30 seconds of backgrounding
- The Clock app works differently - it uses **notification-based timers** that continue even when force-quit

### 2. No Background Update Mechanism
- Live Activities depend on app updates via `LiveActivityService.updateActivity()`
- When app is suspended/terminated, **no updates are sent**
- Live Activity becomes frozen at last known state

### 3. Audio in Background
- Your audio background mode helps but isn't designed for timer continuation
- Chimes may not play reliably during long background periods

## Implementation Plan

### Overview
Enable Live Activities that work like the iPhone Clock app timer - continue updating even when the app is force-quit, with reliable loop completion chimes via notifications.

### Key Design Decisions
1. **Display**: Simple countdown showing remaining time only, with small loop counter
2. **Background Updates**: Use date-based `Text(timerInterval:countsDown:)` for client-side countdown
3. **Chimes**: Pre-schedule local notifications at each loop boundary
4. **Interactive Buttons**: Use App Intents for play/pause and X (exit) buttons
5. **No Background Execution**: Leverage system features instead of keeping app alive

---

## Architecture Changes

### 1. Live Activity Data Model
**File**: `LoopTimerWidgetExtension/TimerActivityAttributes.swift`

**Current ContentState** (requires constant app updates):
```swift
struct ContentState {
    var elapsedTime: TimeInterval  // ❌ Requires app to push updates
    var isRunning: Bool
    var currentLoop: Int
}
```

**New ContentState** (widget calculates countdown):
```swift
struct ContentState {
    var loopEndDate: Date           // ✅ Widget calculates countdown client-side
    var isRunning: Bool
    var currentLoop: Int
    var pausedRemainingTime: TimeInterval?  // For showing time when paused
}
```

### 2. Live Activity UI
**File**: `LoopTimerWidgetExtension/LoopTimerLiveActivity.swift`

**Replace manual time display** with native countdown:
```swift
// Instead of manually showing elapsed/remaining
Text(timerInterval: context.state.loopEndDate..., countsDown: true)
    .font(.system(size: 48, weight: .thin, design: .monospaced))
```

**Add interactive buttons** using App Intents:
```swift
HStack(spacing: 20) {
    // Play/Pause
    Button(intent: ToggleTimerIntent()) {
        Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
    }

    // Exit (X)
    Button(intent: StopTimerIntent()) {
        Image(systemName: "xmark")
    }
}
```

**Layout**:
- Lock Screen: Countdown timer (large), loop counter (small), two buttons below
- Dynamic Island Expanded: Same layout, compact for space
- Dynamic Island Compact: Timer icon + countdown text

### 3. Notification System
**New File**: `LoopTimer/Services/NotificationService.swift`

Schedule notifications at each loop boundary:
```swift
func scheduleLoopNotifications(startDate: Date, duration: TimeInterval, maxLoops: Int = 64) {
    for loopIndex in 1...min(maxLoops, 64) {
        let fireDate = startDate.addingTimeInterval(duration * Double(loopIndex))

        let content = UNMutableNotificationContent()
        content.title = "Loop Timer"
        content.body = "Loop \(loopIndex) complete"
        content.sound = UNNotificationSound(named: selectedSound)
        content.interruptionLevel = .timeSensitive  // Bypass Do Not Disturb

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: fireDate
            ),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "loop-\(loopIndex)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
```

**When notification fires**:
- App foreground: Cancel notification silently (chime already played)
- App background/terminated: Notification plays sound, triggers loop increment

### 4. App Intents for Buttons
**New Files**:
- `LoopTimer/Intents/ToggleTimerIntent.swift`
- `LoopTimer/Intents/StopTimerIntent.swift`

**Implementation**:
```swift
import AppIntents

struct ToggleTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Toggle Timer"

    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .toggleTimerIntent, object: nil)
        return .result()
    }
}

struct StopTimerIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Stop Timer"

    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(name: .stopTimerIntent, object: nil)
        return .result()
    }
}
```

**Handle in TimerViewModel**:
```swift
init() {
    // ... existing code

    NotificationCenter.default.addObserver(
        forName: .toggleTimerIntent,
        object: nil,
        queue: .main
    ) { [weak self] _ in
        self?.togglePlayPause()
    }

    NotificationCenter.default.addObserver(
        forName: .stopTimerIntent,
        object: nil,
        queue: .main
    ) { [weak self] _ in
        self?.stopTimer()
    }
}
```

### 5. Update Strategy - Event-Based, Not Polling

**File**: `LoopTimer/Services/LiveActivityService.swift`

**Remove**: Periodic 5-second update timer

**Update only on**:
- Timer start → Send initial state with `loopEndDate`
- Timer pause → Send `isRunning: false` + `pausedRemainingTime`
- Timer resume → Send `isRunning: true` + new `loopEndDate`
- Loop complete → Send new `currentLoop` + new `loopEndDate`
- Timer stop → End activity

**Key change**: Widget calculates countdown, not the app

### 6. State Restoration on Launch

**File**: `LoopTimer/LoopTimerApp.swift`

Add on app launch:
```swift
Task {
    // Check for active Live Activities
    for activity in Activity<TimerActivityAttributes>.activities {
        let startDate = activity.attributes.startDate
        let duration = activity.attributes.timerDuration

        // Calculate how many loops completed while app was terminated
        let elapsed = Date().timeIntervalSince(startDate)
        let loopsCompleted = Int(elapsed / duration)
        let currentElapsed = elapsed.truncatingRemainder(dividingBy: duration)

        // Restore timer state
        await timerViewModel.restoreFromActivity(
            duration: duration,
            startDate: startDate,
            completedLoops: loopsCompleted,
            currentElapsed: currentElapsed
        )
    }
}
```

---

## Files to Modify

### Core Changes
1. **LoopTimer/Info.plist**
   - Add `NSSupportsLiveActivities = true`
   - Add `NSSupportsLiveActivitiesFrequentUpdates = true`

2. **LoopTimer/LoopTimer.entitlements**
   - Add App Groups: `group.com.monsur.looptimer` (already exists)

3. **LoopTimerWidgetExtension/LoopTimerWidgetExtensionExtension.entitlements** (rename from LoopTimerWidgetExtensionExtension.entitlements)
   - Add App Groups: `group.com.monsur.looptimer`

4. **LoopTimerWidgetExtension/TimerActivityAttributes.swift**
   - Change ContentState: replace `elapsedTime` with `loopEndDate`, add `pausedRemainingTime`

5. **LoopTimerWidgetExtension/LoopTimerLiveActivity.swift**
   - Use `Text(timerInterval:countsDown:)` for countdown
   - Add two `Button(intent:)` for play/pause and exit
   - Simplify UI to show only countdown + loop counter
   - Handle paused state display

6. **LoopTimer/Services/LiveActivityService.swift**
   - Remove periodic update timer
   - Change to event-based updates only
   - Update `startActivity()` to use `loopEndDate`
   - Add `resumeActiveActivities()` method

7. **LoopTimer/Services/TimerService.swift**
   - Add notification scheduling in `start()`
   - Add notification cancellation in `pause()` and `stop()`
   - Add notification rescheduling in `resume()`

8. **LoopTimer/ViewModels/TimerViewModel.swift**
   - Add NotificationCenter observers for App Intents
   - Add notification permission request flow
   - Update to only push Live Activity state changes
   - Add `restoreFromActivity()` method

9. **LoopTimer/LoopTimerApp.swift**
   - Add `UNUserNotificationCenterDelegate` conformance
   - Check for active Live Activities on launch
   - Request notification permissions
   - Handle notification delivery

### New Files to Create

10. **LoopTimer/Services/NotificationService.swift**
    - Schedule loop boundary notifications
    - Cancel pending notifications
    - Request notification permissions
    - Map chime sounds to notification sounds

11. **LoopTimer/Intents/ToggleTimerIntent.swift**
    - Implement `LiveActivityIntent` protocol
    - Post NotificationCenter event for play/pause

12. **LoopTimer/Intents/StopTimerIntent.swift**
    - Implement `LiveActivityIntent` protocol
    - Post NotificationCenter event for stop

13. **LoopTimer/Extensions/Notification+Names.swift**
    - Define notification names: `.toggleTimerIntent`, `.stopTimerIntent`

---

## Implementation Sequence

### Phase 1: Foundation (30 min)
1. Update Info.plist with Live Activity keys
2. Create NotificationService.swift
3. Create Notification+Names.swift extension
4. Request notification permissions on app launch

### Phase 2: Data Model (15 min)
1. Update TimerActivityAttributes ContentState structure
2. Change from `elapsedTime` to `loopEndDate` + `pausedRemainingTime`

### Phase 3: Live Activity UI (45 min)
1. Simplify LoopTimerLiveActivity.swift UI
2. Replace time display with `Text(timerInterval:countsDown:)`
3. Add placeholder buttons (make interactive later)
4. Test basic countdown display

### Phase 4: Notification System (30 min)
1. Integrate NotificationService with TimerService
2. Schedule notifications on timer start
3. Cancel on pause/stop
4. Reschedule on resume
5. Test notification delivery

### Phase 5: Event-Based Updates (30 min)
1. Update LiveActivityService to remove polling
2. Update only on state changes
3. Calculate loopEndDate correctly
4. Handle pause state

### Phase 6: App Intents (45 min)
1. Create ToggleTimerIntent.swift
2. Create StopTimerIntent.swift
3. Wire up buttons in LoopTimerLiveActivity
4. Add observers in TimerViewModel
5. Test button interactions

### Phase 7: State Restoration (30 min)
1. Add activity restoration in LoopTimerApp
2. Handle force-quit recovery
3. Test various edge cases

**Total estimated time: 3-4 hours**

---

## Verification & Testing

### Basic Flow
1. Build and run on **physical device** (Live Activities don't work in simulator)
2. Start timer with 1 minute duration
3. Lock device → Verify countdown continues on lock screen
4. Tap play/pause button → Verify timer pauses
5. Tap X button → Verify timer stops and widget disappears
6. Verify chime plays at 1 minute mark

### Force-Quit Test
1. Start timer
2. Force-quit app (swipe up from app switcher)
3. Wait for loop completion
4. Verify notification fires and plays chime
5. Reopen app
6. Verify timer state restored correctly
7. Verify Live Activity shows correct loop count

### Background Test
1. Start timer with 2 minute loops
2. Press home button (background app)
3. Wait 2 minutes
4. Verify chime plays via notification
5. Check lock screen still shows countdown
6. Reopen app
7. Verify loop counter incremented

### Notification Permission Test
1. Reset notification permissions in Settings
2. Start timer
3. Deny notification permission
4. Verify app shows warning
5. Verify timer still works in foreground
6. Verify Live Activity still shows countdown

### Edge Cases
- Rapid pause/resume
- Device restart during timer
- Change to Do Not Disturb mode
- Multiple timers in quick succession
- Very long timer (20+ loops)

---

## Key Implementation Notes

### Why This Works Like Clock App

1. **Client-Side Countdown**: SwiftUI's `Text(timerInterval:)` runs in widget extension process, continues counting even after app force-quit

2. **Pre-Scheduled Notifications**: `UNNotificationRequest` objects are registered with system, fire independently of app state

3. **No Background Dependencies**: Doesn't rely on app staying alive, background tasks, or audio sessions for timer continuation

4. **State Restoration**: Date-based calculations allow perfect reconstruction of state on app relaunch

5. **System Integration**: Uses iOS's native Live Activity and notification systems designed for this exact use case

### Critical Success Factors

- **Must test on physical device** - Live Activities completely non-functional in simulator
- **Request notification permissions early** - Required for chimes when backgrounded
- **Use `.timeSensitive` notifications** - Ensures chimes play even in Do Not Disturb
- **Handle active activity restoration** - Essential for force-quit recovery
- **App Intents in main target** - System runs LiveActivityIntent in app process, not widget extension

### Limitations

- iOS limits 64 pending notifications (timers longer than 64 loops need batching)
- Live Activities auto-dismiss after ~8 hours of inactivity
- Requires iOS 16.1+ for Live Activities
- Requires iOS 17+ for interactive buttons (App Intents)

---

## Critical Files Summary

**Must Modify**:
- `LoopTimer/Info.plist` - Enable Live Activities
- `LoopTimerWidgetExtension/TimerActivityAttributes.swift` - Date-based ContentState
- `LoopTimerWidgetExtension/LoopTimerLiveActivity.swift` - Countdown UI + buttons
- `LoopTimer/Services/LiveActivityService.swift` - Event-based updates
- `LoopTimer/Services/TimerService.swift` - Notification scheduling
- `LoopTimer/ViewModels/TimerViewModel.swift` - Intent handlers

**Must Create**:
- `LoopTimer/Services/NotificationService.swift` - Notification management
- `LoopTimer/Intents/ToggleTimerIntent.swift` - Play/pause button
- `LoopTimer/Intents/StopTimerIntent.swift` - Exit button
- `LoopTimer/Extensions/Notification+Names.swift` - NotificationCenter names
