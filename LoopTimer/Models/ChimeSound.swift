import Foundation
import AVFoundation

struct ChimeSound: Identifiable, Equatable {
    let id: String  // Unique identifier (same as name)
    let name: String  // Display name
    let fileName: String  // Bundled audio file name (without extension)
    let fileExtension: String  // File extension (mp3, m4a, or caf)

    static let allSounds: [ChimeSound] = [
        ChimeSound(id: "Bell", name: "Bell", fileName: "bell", fileExtension: "caf"),
        ChimeSound(id: "Soft Chime", name: "Soft Chime", fileName: "soft_chime", fileExtension: "caf")
    ]

    static let defaultSound = ChimeSound(id: "Bell", name: "Bell", fileName: "bell", fileExtension: "caf")

    var bundleURL: URL? {
        Bundle.main.url(forResource: fileName, withExtension: fileExtension)
    }
}
