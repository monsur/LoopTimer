//
//  LoopTimerApp.swift
//  LoopTimer
//
//  App entry point and lifecycle management
//

import SwiftUI
import UIKit
import UserNotifications
import ActivityKit

// AppDelegate to handle orientation locking and notification delegation
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    // Handle notifications when app is in foreground - suppress them since the app handles chimes
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Don't show notification banner or play sound when app is in foreground
        // The app will play the chime itself via AudioService
        completionHandler([])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}

@main
struct LoopTimerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationService = NotificationService.shared

    init() {
        checkAndRestoreActiveActivity()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationService)
                .task {
                    await notificationService.checkAuthorizationStatus()
                }
        }
    }

    private func checkAndRestoreActiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let activities = Activity<TimerActivityAttributes>.activities
        if let activeActivity = activities.first {
            // Post notification to restore timer state from active Live Activity
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                NotificationCenter.default.post(
                    name: .restoreTimerState,
                    object: nil,
                    userInfo: [
                        "activityId": activeActivity.id,
                        "attributes": activeActivity.attributes,
                        "contentState": activeActivity.content.state
                    ]
                )
            }
        }
    }
}
