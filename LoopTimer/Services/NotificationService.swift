import Foundation
import UserNotifications
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()

    @Published private(set) var isAuthorized: Bool = false
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let notificationCenter = UNUserNotificationCenter.current()
    private let maxNotifications = 64

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    @MainActor
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
        isAuthorized = settings.authorizationStatus == .authorized
    }

    @MainActor
    func requestPermissions() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("NotificationService: Failed to request permissions: \(error)")
            return false
        }
    }

    func scheduleLoopNotifications(
        startDate: Date,
        duration: TimeInterval,
        soundName: String
    ) async {
        await cancelAllNotifications()

        guard duration > 0 else { return }

        let cafSoundName = cafFileName(for: soundName)

        for loopIndex in 0..<maxNotifications {
            let loopEndDate = startDate.addingTimeInterval(duration * Double(loopIndex + 1))

            guard loopEndDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Loop Complete"
            content.body = "Loop \(loopIndex + 1) finished"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: cafSoundName))
            content.interruptionLevel = .timeSensitive

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: loopEndDate.timeIntervalSinceNow,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "loop-\(loopIndex)",
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                print("NotificationService: Failed to schedule notification \(loopIndex): \(error)")
            }
        }
    }

    func rescheduleFromDate(
        _ resumeDate: Date,
        remainingTimeInCurrentLoop: TimeInterval,
        duration: TimeInterval,
        currentLoop: Int,
        soundName: String
    ) async {
        await cancelAllNotifications()

        guard duration > 0 else { return }

        let cafSoundName = cafFileName(for: soundName)

        let firstLoopEndDate = resumeDate.addingTimeInterval(remainingTimeInCurrentLoop)

        for i in 0..<maxNotifications {
            let loopNumber = currentLoop + i
            let loopEndDate: Date

            if i == 0 {
                loopEndDate = firstLoopEndDate
            } else {
                loopEndDate = firstLoopEndDate.addingTimeInterval(duration * Double(i))
            }

            guard loopEndDate > Date() else { continue }

            let content = UNMutableNotificationContent()
            content.title = "Loop Complete"
            content.body = "Loop \(loopNumber) finished"
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: cafSoundName))
            content.interruptionLevel = .timeSensitive

            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: loopEndDate.timeIntervalSinceNow,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: "loop-\(loopNumber - 1)",
                content: content,
                trigger: trigger
            )

            do {
                try await notificationCenter.add(request)
            } catch {
                print("NotificationService: Failed to schedule notification \(loopNumber): \(error)")
            }
        }
    }

    func cancelAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }

    private func cafFileName(for soundName: String) -> String {
        switch soundName {
        case "Bell":
            return "bell.caf"
        case "Soft Chime":
            return "soft_chime.caf"
        default:
            return "bell.caf"
        }
    }
}
