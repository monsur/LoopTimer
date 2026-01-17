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
            // Play/Pause Button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onPlayPause()
            }) {
                Image(systemName: playPauseIcon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(Color.blue)
                    )
            }
            .buttonStyle(.plain)
            .scaleEffect(state == .running ? 1.0 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: state)

            // Stop Button (only shown when timer is active)
            if state != .idle {
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onStop()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.red)
                        )
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding()
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
