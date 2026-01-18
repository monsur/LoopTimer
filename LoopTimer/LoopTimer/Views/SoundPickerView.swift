import SwiftUI
import AVFoundation

struct SoundPickerView: View {
    @AppStorage("selectedChimeSound") private var selectedSound: String = "Bell"
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        List {
            ForEach(ChimeSound.allSounds) { sound in
                Button(action: {
                    selectedSound = sound.id
                    playPreview(sound: sound)
                }) {
                    HStack {
                        Text(sound.name)
                            .foregroundColor(.primary)

                        Spacer()

                        if sound.id == selectedSound {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Sounds")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func playPreview(sound: ChimeSound) {
        guard let soundURL = sound.bundleURL else {
            print("Sound file not found: \(sound.fileName).\(sound.fileExtension)")
            return
        }

        do {
            // Configure audio session for preview
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)

            // Create and play audio
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to preview sound: \(error)")
        }
    }
}
