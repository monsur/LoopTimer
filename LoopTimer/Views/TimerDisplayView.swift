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
    let isPaused: Bool
    var onTap: (() -> Void)? = nil

    private var textColor: Color {
        isIdle || isPaused ? .secondary : .primary
    }

    var body: some View {
        HStack(spacing: 4) {
            Text(displayMode == .elapsed ? "+" : "-")
                .font(.system(size: 70, weight: .thin, design: .monospaced))
                .foregroundColor(textColor)

            Text(timeInterval.formattedTime())
                .font(.system(size: 70, weight: .thin, design: .monospaced))
                .foregroundColor(textColor)
                .animation(.easeInOut(duration: 0.3), value: timeInterval)
                .contentTransition(.numericText(countsDown: displayMode == .remaining))
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
        TimerDisplayView(timeInterval: 0, isIdle: true, isPaused: false)
        TimerDisplayView(timeInterval: 125.5, displayMode: .elapsed, isIdle: false, isPaused: false)
        TimerDisplayView(timeInterval: 175, displayMode: .remaining, isIdle: false, isPaused: true)
        TimerDisplayView(timeInterval: 3665, displayMode: .elapsed, isIdle: false, isPaused: false)
    }
}
