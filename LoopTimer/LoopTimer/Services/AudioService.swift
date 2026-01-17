//
//  AudioService.swift
//  LoopTimer
//
//  Audio session setup and chime playback
//

import AVFoundation
import Foundation

class AudioService {
    private var audioPlayer: AVAudioPlayer?
    private var currentChime: ChimeOption

    init(chime: ChimeOption = .bell) {
        self.currentChime = chime
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

    func setChime(_ chime: ChimeOption) {
        currentChime = chime
        prepareAudioPlayer()
    }

    func playChime() {
        guard currentChime != .none else { return }

        // Ensure audio session is active
        setupAudioSession()

        // Play the chime
        audioPlayer?.play()
    }

    func previewChime(_ chime: ChimeOption) {
        guard chime != .none else { return }

        // Temporarily prepare and play the preview chime
        if let fileName = chime.fileName,
           let soundURL = Bundle.main.url(forResource: fileName, withExtension: "caf") {
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                player.play()
            } catch {
                print("Failed to play preview chime: \(error)")
            }
        }
    }

    // MARK: - Private Methods

    private func prepareAudioPlayer() {
        guard let fileName = currentChime.fileName else {
            audioPlayer = nil
            return
        }

        guard let soundURL = Bundle.main.url(forResource: fileName, withExtension: "caf") else {
            print("Audio file not found: \(fileName).caf")
            audioPlayer = nil
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Failed to prepare audio player: \(error)")
            audioPlayer = nil
        }
    }
}
