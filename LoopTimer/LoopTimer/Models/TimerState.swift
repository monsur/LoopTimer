//
//  TimerState.swift
//  LoopTimer
//
//  Timer state enumeration
//

import Foundation

enum TimerState: String, Codable {
    case idle
    case running
    case paused
}
