//
//  ChimeOption.swift
//  LoopTimer
//
//  Chime sound options with file mapping
//

import Foundation

enum ChimeOption: String, CaseIterable, Identifiable {
    case bell = "Bell"
    case soft = "Soft Chime"
    case digital = "Digital"
    case none = "None"

    var id: String { rawValue }

    var fileName: String? {
        switch self {
        case .bell:
            return "chime_bell"
        case .soft:
            return "chime_soft"
        case .digital:
            return "chime_digital"
        case .none:
            return nil
        }
    }

    var description: String {
        switch self {
        case .bell:
            return "Classic bell sound"
        case .soft:
            return "Gentle chime"
        case .digital:
            return "Digital beep"
        case .none:
            return "No sound"
        }
    }
}
