//
//  TimerPickerView.swift
//  LoopTimer
//
//  Time duration picker (minutes, seconds)
//

import SwiftUI

struct TimerPickerView: View {
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        HStack(spacing: 0) {
            // Minutes
            Picker("Minutes", selection: $minutes) {
                ForEach(0..<100, id: \.self) { minute in
                    Text("\(minute)")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)

            Text("m")
                .font(.title)
                .foregroundColor(.secondary)
                .frame(width: 40)

            // Seconds
            Picker("Seconds", selection: $seconds) {
                ForEach(0..<60, id: \.self) { second in
                    Text("\(second)")
                        .tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 100)

            Text("s")
                .font(.title)
                .foregroundColor(.secondary)
                .frame(width: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimerPickerView(minutes: .constant(5), seconds: .constant(30))
}
