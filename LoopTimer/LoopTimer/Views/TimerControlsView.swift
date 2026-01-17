//
//  TimerControlsView.swift
//  LoopTimer
//
//  Play/pause and stop button controls
//

import SwiftUI

struct TimerControlsView: View {
    let state: TimerState
    let onPlayPause: () -> Void
    let onStop: () -> Void

    var body: some View {
        HStack(spacing: 40) {
            // Single Play/Pause Button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()

                // togglePlayPause handles all states: idle->start, running->pause, paused->resume
                onPlayPause()
            }) {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(buttonColor)
                    )
            }
            .buttonStyle(.plain)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: state)
        }
        .padding()
    }

    private var buttonColor: Color {
        state == .running ? .red : .blue
    }

    private var playPauseIcon: String {
        switch state {
        case .idle, .paused:
            return "play.fill"
        case .running:
            return "pause.fill"
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        TimerControlsView(state: .idle, onPlayPause: {}, onStop: {})
        TimerControlsView(state: .running, onPlayPause: {}, onStop: {})
        TimerControlsView(state: .paused, onPlayPause: {}, onStop: {})
    }
    .padding()
}
