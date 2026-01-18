import Foundation
import AVFoundation

struct ChimeSound: Identifiable, Equatable {
    let id: String  // Unique identifier (same as name)
    let name: String  // Display name
    let fileName: String  // Bundled audio file name (without extension)
    let fileExtension: String  // File extension (mp3, m4a, or caf)

    static let allSounds: [ChimeSound] = [
        ChimeSound(id: "Bell", name: "Bell", fileName: "bell", fileExtension: "mp3"),
        ChimeSound(id: "Soft Chime", name: "Soft Chime", fileName: "soft_chime", fileExtension: "mp3")
        // Add more sounds as you download them:
        // ChimeSound(id: "Glass", name: "Glass", fileName: "glass", fileExtension: "mp3"),
        // ChimeSound(id: "Digital", name: "Digital", fileName: "digital", fileExtension: "mp3"),
        // ChimeSound(id: "Bamboo", name: "Bamboo", fileName: "bamboo", fileExtension: "mp3"),
        // ChimeSound(id: "Ascending", name: "Ascending", fileName: "ascending", fileExtension: "mp3"),
        // ChimeSound(id: "Descending", name: "Descending", fileName: "descending", fileExtension: "mp3"),
        // ChimeSound(id: "Complete", name: "Complete", fileName: "complete", fileExtension: "mp3"),
        // ChimeSound(id: "Pulse", name: "Pulse", fileName: "pulse", fileExtension: "mp3"),
        // ChimeSound(id: "Bright", name: "Bright", fileName: "bright", fileExtension: "mp3")
    ]

    static let defaultSound = ChimeSound(id: "Bell", name: "Bell", fileName: "bell", fileExtension: "mp3")

    var bundleURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
}
