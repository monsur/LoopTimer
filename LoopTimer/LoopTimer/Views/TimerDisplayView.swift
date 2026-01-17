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
    var onTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            if !isIdle {
                Text(displayMode == .elapsed ? "+" : "-")
                    .font(.system(size: 60, weight: .thin, design: .monospaced))
                    .foregroundColor(.secondary)
            }

            Text(timeInterval.formattedTime())
                .font(.system(size: 60, weight: .thin, design: .monospaced))
                .foregroundColor(isIdle ? .secondary : .primary)
                .animation(.easeInOut(duration: 0.3), value: timeInterval)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
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
