//
//  TimerPickerView.swift
//  LoopTimer
//
//  Time duration picker (hours, minutes, seconds)
//

import SwiftUI

struct TimerPickerView: View {
    @Binding var hours: Int
    @Binding var minutes: Int
    @Binding var seconds: Int

    var body: some View {
        HStack(spacing: 0) {
            // Hours
            Picker("Hours", selection: $hours) {
                ForEach(0..<24, id: \.self) { hour in
                    Text("\(hour)")
                        .tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("h")
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(width: 30)

            // Minutes
            Picker("Minutes", selection: $minutes) {
                ForEach(0..<60, id: \.self) { minute in
                    Text("\(minute)")
                        .tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("m")
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(width: 30)

            // Seconds
            Picker("Seconds", selection: $seconds) {
                ForEach(0..<60, id: \.self) { second in
                    Text("\(second)")
                        .tag(second)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 80)

            Text("s")
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(width: 30)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    TimerPickerView(hours: .constant(0), minutes: .constant(5), seconds: .constant(30))
}
