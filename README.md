# Loop Timer for iOS

A minimalist iOS timer app with automatic looping functionality, lock screen integration, and persistent history.

## Features

- **⭕ Automatic Looping**: Timer automatically restarts when it reaches zero
- **⏸️ Play/Pause Controls**: Start, pause, and resume the timer
- **🔄 Display Toggle**: Switch between time elapsed and time remaining
- **📜 Timer History**: Persistent list of previous timer sessions
- **🔔 Chime Sounds**: Customizable sounds on loop completion (Bell, Soft, Digital, None)
- **🔒 Lock Screen**: Live Activities show timer on lock screen with live updates
- **🌙 Background Operation**: Timer continues running when app is backgrounded or screen is locked
- **⚙️ Time Input**: Easy picker wheel interface (hours/minutes/seconds)
- **🎨 Minimalist Design**: Clean, simple, and focused interface

## Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Quick Start

1. **Clone or download this repository**
2. **Follow the [SETUP_GUIDE.md](SETUP_GUIDE.md)** for detailed Xcode project setup instructions
3. **Add audio files** (see `LoopTimer/Resources/AUDIO_FILES_README.md`)
4. **Build and run** on your device

## Project Structure

```
LoopTimer/
├── Models/              # Data models (SwiftData & enums)
├── Services/            # Business logic (Timer, Audio, Live Activities)
├── ViewModels/          # MVVM coordinators
├── Views/              # SwiftUI views
├── Extensions/         # Helper extensions
└── Resources/          # Audio files and assets

LoopTimerWidgetExtension/
└── Live Activity widget implementation
```

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture with service layer:

- **Models**: SwiftData models and value types
- **Services**: Core functionality (timer logic, audio, persistence, live activities)
- **ViewModels**: Coordinate services and manage UI state
- **Views**: SwiftUI views (presentation layer)

## Key Technical Decisions

### Timer Implementation
- Uses `DispatchSourceTimer` for better background performance
- Date-based calculations prevent timer drift
- State restoration survives app termination

### Audio Playback
- `AVAudioSession` with `.playback` category
- Plays even when device is on silent (like alarm apps)
- Automatically routes to headphones/speaker

### Persistence
- SwiftData for timer history
- UserDefaults for timer state restoration
- Minimal setup required

### Live Activities
- ActivityKit integration
- Displays on lock screen and Dynamic Island
- Auto-updates with timer progress

## Testing

See [SETUP_GUIDE.md](SETUP_GUIDE.md) for comprehensive testing checklist including:

- Basic timer functionality
- Audio playback
- History persistence
- Background operation
- Live Activities (requires physical device)

## Implementation Phases

This project was built in 5 phases:

1. **Phase 1**: Core timer foundation
2. **Phase 2**: Audio integration
3. **Phase 3**: Persistence & history
4. **Phase 4**: Live Activities
5. **Phase 5**: Background operation & polish

Each phase was tested before moving to the next, ensuring a solid foundation.

## Known Limitations

- Live Activities don't work in iOS Simulator (requires physical device)
- Live Activities auto-dismiss after 8 hours (iOS limitation)
- Timer doesn't survive device reboot (expected behavior)

## Future Enhancements

Possible features for future versions:

- [ ] Loop counter display ("Loop 3 of ∞")
- [ ] Multiple concurrent timers
- [ ] Preset timer buttons (30s, 1m, 5m quick start)
- [ ] Apple Watch companion app
- [ ] Siri shortcuts integration
- [ ] Home Screen widget
- [ ] iCloud sync for history
- [ ] Timer statistics
- [ ] Custom chime upload

## Contributing

This is a personal project, but suggestions and feedback are welcome. Feel free to fork and modify for your own use.

## License

This project is provided as-is for educational and personal use.

## Acknowledgments

Built with:
- SwiftUI
- SwiftData
- ActivityKit
- AVFoundation
- DispatchSourceTimer

References:
- [Apple's Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Background Execution Best Practices](https://developer.apple.com/documentation/avfoundation/media_playback/configuring_your_app_for_media_playback)
- [Live Activities Documentation](https://developer.apple.com/documentation/activitykit/displaying-live-data-with-live-activities)

---

Built with ❤️ using SwiftUI and modern iOS development practices.
