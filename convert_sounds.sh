#!/bin/bash
# Run this script on macOS to convert MP3 files to CAF format for iOS notifications
# CAF format is required for custom notification sounds

SOUNDS_DIR="LoopTimer/Resources/Sounds"

cd "$(dirname "$0")"

if [ ! -d "$SOUNDS_DIR" ]; then
    echo "Error: Sounds directory not found at $SOUNDS_DIR"
    exit 1
fi

echo "Converting bell.mp3 to CAF..."
afconvert "$SOUNDS_DIR/bell.mp3" "$SOUNDS_DIR/bell.caf" -d LEI16 -f 'caff'

echo "Converting soft_chime.mp3 to CAF..."
afconvert "$SOUNDS_DIR/soft_chime.mp3" "$SOUNDS_DIR/soft_chime.caf" -d LEI16 -f 'caff'

echo "Done! CAF files created in $SOUNDS_DIR"
echo ""
echo "=============================================="
echo "XCODE PROJECT SETUP INSTRUCTIONS"
echo "=============================================="
echo ""
echo "1. SOUND FILES:"
echo "   - Drag bell.caf and soft_chime.caf into your Xcode project"
echo "   - Ensure they are added to the main app target"
echo ""
echo "2. NEW SOURCE FILES - Add to main app target:"
echo "   - LoopTimer/Services/NotificationService.swift"
echo "   - LoopTimer/Extensions/Notification+Names.swift"
echo "   - LoopTimer/Intents/ToggleTimerIntent.swift"
echo "   - LoopTimer/Intents/StopTimerIntent.swift"
echo ""
echo "3. INTENT FILES - Add to BOTH targets:"
echo "   The intent files (ToggleTimerIntent.swift and StopTimerIntent.swift)"
echo "   must be added to BOTH the main app AND widget extension targets:"
echo "   - Select each intent file in Xcode"
echo "   - Open the File Inspector (right panel)"
echo "   - Under 'Target Membership', check BOTH:"
echo "     [x] LoopTimer"
echo "     [x] LoopTimerWidgetExtension"
echo ""
echo "4. VERIFY Info.plist entries are present:"
echo "   - NSSupportsLiveActivities = YES"
echo "   - NSSupportsLiveActivitiesFrequentUpdates = YES"
echo ""
echo "5. BUILD AND TEST:"
echo "   - Clean build folder (Cmd+Shift+K)"
echo "   - Build and run on a PHYSICAL DEVICE"
echo "   - Live Activities don't work in the simulator"
echo "=============================================="
