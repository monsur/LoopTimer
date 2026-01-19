# Running Loop Timer on Your iPhone

This guide explains how to install and run the Loop Timer app on your physical iPhone device.

## Prerequisites

1. **Mac with Xcode 15.0 or later**
2. **iPhone with iOS 17.0 or later**
3. **Apple ID** (free Apple Developer account is sufficient for personal testing)
4. **USB cable** to connect your iPhone to your Mac

## Steps to Run on Your iPhone

### 1. Configure Xcode Project

Open the Xcode project:
```bash
open LoopTimer.xcodeproj
```

### 2. Set Up Code Signing

In Xcode:
- Select the project in the navigator (LoopTimer)
- Select the **LoopTimer** target
- Go to **Signing & Capabilities** tab
- Check "Automatically manage signing"
- Select your Apple ID team from the dropdown
- Repeat for the **LoopTimerWidgetExtension** target

### 3. Connect Your iPhone

- Connect your iPhone to your Mac with USB
- On your iPhone, tap "Trust This Computer" when prompted
- Unlock your device

### 4. Select Your Device in Xcode

- In the Xcode toolbar, click the device selector (next to the scheme)
- Choose your iPhone from the list

### 5. Build and Run

- Click the Play button (▶️) in Xcode, or press `Cmd + R`
- The first time, you may need to trust the developer certificate on your iPhone:
  - Go to **Settings > General > VPN & Device Management**
  - Tap your Apple ID
  - Tap "Trust [Your Apple ID]"

### 6. Enable Live Activities (Optional)

For the lock screen timer feature to work:
- On your iPhone: **Settings > Face ID & Passcode** (or Touch ID & Passcode)
- Scroll down and ensure "Live Activities" is enabled

## Notes

- Audio files are already present (bell.caf and soft_chime.caf)
- The app will request notification permissions on first launch
- Live Activities only work on physical devices (not simulator)
- No paid Apple Developer account needed for personal testing
- Your app certificate is valid for 7 days with a free account (needs re-signing after that)

## Troubleshooting

### "Failed to Register Bundle Identifier"
- Change the Bundle Identifier in project settings to something unique
- Use reverse domain notation: `com.yourname.looptimer`

### "Untrusted Developer"
- Go to Settings > General > VPN & Device Management
- Find your Apple ID and tap "Trust"

### Live Activities Not Showing
- Ensure you're on a physical device (not simulator)
- Check that Live Activities are enabled in Settings
- Restart the app

### Audio Not Playing
- Check device is not in silent mode (app plays even in silent mode like alarms)
- Ensure volume is turned up
- Check audio files are in LoopTimer/Resources/Sounds/
