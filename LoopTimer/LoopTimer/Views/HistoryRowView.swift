//
//  HistoryRowView.swift
//  LoopTimer
//
//  Individual history list item
//

import SwiftUI

struct HistoryRowView: View {
    let instance: TimerInstance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Duration
                Text(instance.durationString)
                    .font(.headline)

                Spacer()

                // Completed loops badge
                if instance.completedLoops > 0 {
                    Text("\(instance.completedLoops) loops")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(8)
                }
            }

            HStack {
                // Chime info
                Image(systemName: instance.chimeName == ChimeOption.none.rawValue ? "speaker.slash" : "speaker.wave.2")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(instance.chimeName)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                // Time
                Text(instance.startedAt.relativeFormatted())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
