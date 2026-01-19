//
//  AudioService.swift
//  LoopTimer
//
//  Audio session setup and chime playback
//

import AVFoundation
import AudioToolbox
import Foundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?

    init() {
        setupAudioSession()
    }

    // MARK: - Audio Session Setup

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()

            // Set category to .playback to ensure:
            // - Audio plays even when device is on silent
            // - Audio continues in background
            // - Similar behavior to Clock app alarms
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)

            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }

    // MARK: - Public Methods

    func playChime(soundName: String = "Bell", isMuted: Bool = false) {
        // Early exit if muted
        guard !isMuted else {
            print("Audio muted, skipping chime playback")
            return
        }

        // Find the sound in the list
        guard let sound = ChimeSound.allSounds.first(where: { $0.id == soundName }) else {
            print("Sound not found: \(soundName), using fallback")
            AudioServicesPlaySystemSound(1013)  // System bell fallback
            return
        }

        // Get URL from bundle
        guard let soundURL = sound.bundleURL else {
            print("Sound file not found in bundle: \(sound.fileName).\(sound.fileExtension)")
            AudioServicesPlaySystemSound(1013)  // System bell fallback
            return
        }

        do {
            // Ensure audio session is active
            try AVAudioSession.sharedInstance().setActive(true)

            // Create and play audio player
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Failed to play sound from bundle: \(error)")
            // Fallback to system sound
            AudioServicesPlaySystemSound(1013)
        }
    }
}
