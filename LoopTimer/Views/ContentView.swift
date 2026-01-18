//
//  ContentView.swift
//  LoopTimer
//
//  Main app container - single timer view
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TimerView()
            .persistentSystemOverlays(.hidden)
            .onAppear {
                // Lock to portrait orientation
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
            }
    }
}

#Preview {
    ContentView()
}
