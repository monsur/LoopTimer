# Audio Files for Loop Timer

This directory should contain the chime sound files in CAF (Core Audio Format) format.

## Required Files

1. **chime_bell.caf** - Classic bell sound
2. **chime_soft.caf** - Gentle chime sound
3. **chime_digital.caf** - Digital beep sound

## How to Create CAF Files

You can convert audio files (MP3, WAV, etc.) to CAF format using the `afconvert` command-line tool included with macOS:

```bash
# Convert an audio file to CAF format
afconvert input_file.mp3 -o chime_bell.caf -d ima4 -f caff -v

# Example for all three files:
afconvert bell_sound.mp3 -o chime_bell.caf -d ima4 -f caff -v
afconvert soft_sound.wav -o chime_soft.caf -d ima4 -f caff -v
afconvert digital_beep.mp3 -o chime_digital.caf -d ima4 -f caff -v
```

### Parameters Explained
- `-o` - Output file name
- `-d ima4` - Data format (IMA4 ADPCM compression, good for short sounds)
- `-f caff` - File format (Core Audio Format)
- `-v` - Verbose output

### Alternative Formats
You can also use AAC encoding for better quality:
```bash
afconvert input_file.mp3 -o chime_bell.caf -d aac -f caff -v
```

## Finding Free Sound Files

You can find free sound effects from:
- **Freesound.org** - Community-uploaded sound effects
- **Zapsplat.com** - Free sound effects library
- **SoundBible.com** - Public domain sounds

Search for terms like "bell", "chime", "ding", "beep" to find suitable sounds.

## File Recommendations

- **Duration**: 0.5 - 2 seconds (short and non-intrusive)
- **Format**: CAF with IMA4 or AAC codec
- **Sample Rate**: 44.1 kHz or 48 kHz
- **Bit Depth**: 16-bit or higher

## Adding Files to Xcode

1. Place the .caf files in the `LoopTimer/Resources/Sounds/` directory
2. In Xcode, right-click the `Resources/Sounds` group
3. Select "Add Files to 'LoopTimer'..."
4. Choose your .caf files
5. Ensure "Copy items if needed" is checked
6. Ensure your app target is selected

The audio files will then be bundled with your app and available at runtime.
