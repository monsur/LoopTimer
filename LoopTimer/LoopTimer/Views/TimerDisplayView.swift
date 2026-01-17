//
//  TimerDisplayView.swift
//  LoopTimer
//
//  Large time display component
//

import SwiftUI

struct TimerDisplayView: View {
    let timeInterval: TimeInterval
    var displayMode: DisplayMode = .elapsed
    let isIdle: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(timeInterval.formattedTime())
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundColor(isIdle ? .secondary : .primary)
                .animation(.easeInOut(duration: 0.3), value: timeInterval)
                .contentTransition(.numericText())

            if !isIdle {
                Text(displayMode.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .animation(.easeInOut(duration: 0.3), value: displayMode)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    VStack(spacing: 40) {
        TimerDisplayView(timeInterval: 0, isIdle: true)
        TimerDisplayView(timeInterval: 125.5, displayMode: .elapsed, isIdle: false)
        TimerDisplayView(timeInterval: 175, displayMode: .remaining, isIdle: false)
        TimerDisplayView(timeInterval: 3665, displayMode: .elapsed, isIdle: false)
    }
}
