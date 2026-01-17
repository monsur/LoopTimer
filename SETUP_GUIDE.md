# Loop Timer - Xcode Project Setup Guide

This guide will help you set up the Xcode project for the Loop Timer app.

## Prerequisites

- macOS with Xcode 15.0 or later
- iOS 17.0 SDK or later
- Apple Developer account (for running on device and testing Live Activities)

## Step 1: Create Xcode Project

1. Open Xcode
2. Select **File → New → Project**
3. Choose **iOS → App**
4. Configure project:
   - **Product Name**: LoopTimer
   - **Team**: Select your development team
   - **Organization Identifier**: com.yourcompany (use your own)
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Storage**: SwiftData
   - **Include Tests**: Optional
5. Save the project in `/Users/monsur/Documents/Projects/looptimer/`

## Step 2: Add Source Files to Project

### Main App Target

1. In Xcode, right-click the **LoopTimer** group in the navigator
2. Select **Add Files to "LoopTimer"...**
3. Navigate to the `LoopTimer` folder you created
4. Select all folders: **Models**, **Services**, **ViewModels**, **Views**, **Extensions**, **Resources**
5. Ensure these options are checked:
   - ✅ Copy items if needed
   - ✅ Create groups
   - ✅ LoopTimer target is selected
6. Click **Add**

7. **Important**: Also add the following files to the root of the LoopTimer group:
   - `LoopTimer/LoopTimerApp.swift`
   - `LoopTimer/Info.plist`

### Configure Info.plist

1. Select your project in the navigator
2. Select the **LoopTimer** target
3. Go to the **Info** tab
4. Right-click in the custom properties area and select **Open As → Source Code**
5. Replace the contents with the Info.plist file from `LoopTimer/Info.plist`

Alternatively, add these keys manually:
- **UIBackgroundModes** → Add item → **audio**
- **NSSupportsLiveActivities** → **YES**

## Step 3: Create Widget Extension Target

1. In Xcode, select **File → New → Target**
2. Choose **iOS → Widget Extension**
3. Configure:
   - **Product Name**: LoopTimerWidgetExtension
   - **Include Live Activity**: ✅ Check this box
   - Click **Finish**
   - When prompted "Activate scheme?", click **Activate**

4. Delete the default widget files Xcode created:
   - Delete `LoopTimerWidgetExtensionLiveActivity.swift` (if created)
   - Delete `LoopTimerWidgetExtensionBundle.swift`
   - Delete any other default files

5. Add widget extension files:
   - Right-click **LoopTimerWidgetExtension** group
   - Select **Add Files to "LoopTimerWidgetExtension"...**
   - Navigate to `LoopTimerWidgetExtension` folder
   - Select all `.swift` files
   - Ensure **LoopTimerWidgetExtension** target is selected
   - Click **Add**

## Step 4: Configure Capabilities

### Main App Target

1. Select your project → **LoopTimer** target → **Signing & Capabilities**
2. Click **+ Capability** and add:
   - **App Groups**
     - Click **+** and create: `group.com.yourcompany.looptimer`
     - Replace `yourcompany` with your organization identifier
   - Ensure **Background Modes** capability shows **Audio** (should be auto-added from Info.plist)

### Widget Extension Target

1. Select **LoopTimerWidgetExtension** target → **Signing & Capabilities**
2. Click **+ Capability** and add:
   - **App Groups**
     - Select the same group: `group.com.yourcompany.looptimer`

## Step 5: Add Audio Files

The app requires three chime sound files in CAF format:

1. Create or obtain audio files (see `LoopTimer/Resources/AUDIO_FILES_README.md` for details)
2. Convert to CAF format using Terminal:
   ```bash
   cd LoopTimer/Resources/Sounds
   afconvert your_bell.mp3 -o chime_bell.caf -d ima4 -f caff -v
   afconvert your_soft.mp3 -o chime_soft.caf -d ima4 -f caff -v
   afconvert your_digital.mp3 -o chime_digital.caf -d ima4 -f caff -v
   ```

3. In Xcode, right-click **Resources/Sounds** group
4. Select **Add Files to "LoopTimer"...**
5. Choose your three `.caf` files
6. Ensure **LoopTimer** target is selected
7. Click **Add**

### Quick Audio File Option

If you don't have audio files ready, you can use system sounds temporarily:
- Use any short audio file (MP3, WAV, etc.)
- Convert using the `afconvert` command above
- Or download free sounds from:
  - https://freesound.org
  - https://zapsplat.com

## Step 6: Share Code Between Targets

The Widget Extension needs access to some models from the main app:

1. Select `LoopTimer/Models/TimerState.swift`
2. In the File Inspector (right panel), under **Target Membership**:
   - ✅ LoopTimer
   - ✅ LoopTimerWidgetExtension

3. Repeat for these files:
   - `LoopTimer/Models/DisplayMode.swift`
   - `LoopTimer/Extensions/TimeInterval+Extensions.swift`
   - `LoopTimerWidgetExtension/TimerActivityAttributes.swift` (add to LoopTimer target too)

## Step 7: Build and Run

### Simulator Testing

1. Select an iOS 17.0+ simulator
2. Click **Run** (Cmd+R)
3. The app should build and launch

**Note**: Live Activities don't work in the simulator. You'll need a physical device to test lock screen features.

### Device Testing

1. Connect an iPhone running iOS 17.0 or later
2. Select your device in the scheme selector
3. Click **Run**
4. Test Live Activities:
   - Start a timer
   - Lock your device
   - The timer should appear on the lock screen

## Step 8: Fix Common Build Issues

### Issue: "Cannot find type 'Activity' in scope"

**Solution**: Ensure ActivityKit is imported in `LiveActivityService.swift`:
```swift
import ActivityKit
```

### Issue: "Module 'SwiftData' not found"

**Solution**:
1. Select your target
2. Go to **Build Phases → Link Binary With Libraries**
3. Click **+** and add **SwiftData.framework**

### Issue: "Audio files not found"

**Solution**:
1. Select each `.caf` file in the navigator
2. Check **Target Membership** includes **LoopTimer**
3. Verify files are in **Build Phases → Copy Bundle Resources**

### Issue: Widget extension won't build

**Solution**:
1. Ensure `TimerActivityAttributes.swift` is added to **both** targets
2. Verify App Groups capability matches between targets
3. Clean build folder: **Product → Clean Build Folder** (Cmd+Shift+K)

## Step 9: Testing Checklist

Once the app builds successfully, test these features:

### Basic Timer Features
- [ ] Start timer with custom duration
- [ ] Timer counts up correctly
- [ ] Timer loops automatically when reaching duration
- [ ] Pause/resume works correctly
- [ ] Stop button ends timer and resets

### Audio
- [ ] Chime plays when loop completes
- [ ] Chime selection in Settings works
- [ ] Preview button plays chime
- [ ] Chime plays when device is on silent

### History
- [ ] Timer instance saved when stopped
- [ ] History shows completed timers
- [ ] Swipe to delete works
- [ ] History persists after app restart

### Display Mode
- [ ] Toggle shows when timer is active
- [ ] Elapsed time shows correctly
- [ ] Remaining time shows correctly
- [ ] Display updates when toggling

### Background Operation
- [ ] Timer continues when app is backgrounded
- [ ] Chime plays when app is in background
- [ ] Timer continues when screen is locked
- [ ] Timer state restored after force quit and relaunch

### Live Activities (Device Only)
- [ ] Live Activity appears on lock screen when timer starts
- [ ] Time updates on lock screen
- [ ] Progress bar displays correctly
- [ ] Loop counter updates
- [ ] Activity dismisses when timer stops

## Deployment Minimum Requirements

- **iOS Deployment Target**: 17.0
- **Xcode Version**: 15.0 or later
- **Swift Version**: 5.9 or later

## App Store Submission (Future)

Before submitting to the App Store:

1. Add app icons in **Assets.xcassets → AppIcon**
2. Configure launch screen
3. Add privacy policy (if collecting user data)
4. Test on multiple devices and iOS versions
5. Configure version and build numbers
6. Add App Store screenshots and description
7. Submit for review through App Store Connect

## Troubleshooting

### Live Activities Not Showing

1. Ensure device is running iOS 17.0+
2. Check that `NSSupportsLiveActivities` is `true` in Info.plist
3. Verify App Groups capability is configured correctly
4. Check Console logs for Live Activity errors

### Timer Not Accurate After Background

1. Verify `UIBackgroundModes` includes `audio` in Info.plist
2. Check that AudioService is calling `setActive(true)`
3. Ensure timer uses Date-based calculations (not cumulative ticks)

### State Not Restored After Force Quit

1. Check UserDefaults is saving correctly in `TimerService.saveState()`
2. Verify `restoreState()` is called in `TimerService.init()`
3. Look for saved values in UserDefaults:
   ```swift
   print(UserDefaults.standard.string(forKey: "timerState"))
   ```

## Additional Resources

- [SwiftData Documentation](https://developer.apple.com/documentation/SwiftData)
- [Live Activities Guide](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)
- [Background Execution](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback)
- [AVAudioSession](https://developer.apple.com/documentation/avfaudio/avaudiosession)

## Support

For issues or questions about the implementation, refer to:
- The original implementation plan
- Code comments in each Swift file
- Apple's official documentation linked above

---

**Ready to build!** Follow the steps above and you'll have a fully functional looping timer app with lock screen integration.
