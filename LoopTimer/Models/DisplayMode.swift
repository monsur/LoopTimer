//
//  DisplayMode.swift
//  LoopTimer
//
//  Display mode for elapsed vs remaining time
//

import Foundation

enum DisplayMode: String, CaseIterable, Codable {
    case elapsed = "Time Elapsed"
    case remaining = "Time Remaining"

    mutating func toggle() {
        self = self == .elapsed ? .remaining : .elapsed
    }
}
