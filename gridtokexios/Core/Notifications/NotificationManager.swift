//
//  NotificationManager.swift
//  gridtokexios
//
//  User notifications (UNUserNotificationCenter): authorization + local
//  notification delivery. Registering here is what makes the app's
//  Notifications settings entry appear and lets banners show. Separate from
//  the ActivityKit Live Activity (see LiveActivityManager).
//

import Foundation
import UserNotifications

enum NotificationManager {
    private static var center: UNUserNotificationCenter { .current() }

    /// Posted when the user taps a notification carrying a `deeplink` payload.
    /// `userInfo["deeplink"]` holds the destination string (e.g. "wallet").
    /// RootView observes this to navigate.
    static let didTapDeeplink = Notification.Name("gtx.notification.didTapDeeplink")

    /// Install the foreground-presentation delegate and request permission.
    /// Call once at launch. The delegate is what lets banners appear while the
    /// app is in the foreground; without it iOS suppresses them.
    static func configure() {
        center.delegate = ForegroundPresenter.shared
        requestAuthorization()
    }

    /// Ask the user for alert/sound/badge permission. Triggers the system
    /// "Allow Notifications?" dialog the first time; afterward the choice lives
    /// in Settings ▸ gridtokexios ▸ Notifications. Idempotent to call on launch.
    static func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Schedule a local notification. No-op if the user denied authorization —
    /// the system silently drops it. `delay` is seconds from now (min 1).
    /// `deeplink` (if set) routes the app when the banner is tapped.
    static func send(title: String, body: String, subtitle: String? = nil,
                     deeplink: String? = nil, after delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle { content.subtitle = subtitle }
        content.body = body
        content.sound = .default
        if let deeplink { content.userInfo = ["deeplink": deeplink] }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    /// Sample energy-trade notification for testing. Taps open Profile & Wallet.
    static func sendSample() {
        send(
            title: "GridTokenX",
            body: "Selling 5.4 kWh at ฿4.31/kWh · Zone 2",
            subtitle: "Energy trade live",
            deeplink: "wallet"
        )
    }
}

/// Presents banners while the app is in the foreground. Without a delegate
/// returning `.banner`, iOS only shows foreground notifications in the list.
private final class ForegroundPresenter: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ForegroundPresenter()

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .list])
    }

    /// Fired when the user taps a delivered notification. Re-broadcasts any
    /// `deeplink` payload so the UI layer can navigate.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if let deeplink = response.notification.request.content.userInfo["deeplink"] as? String {
            NotificationCenter.default.post(
                name: NotificationManager.didTapDeeplink,
                object: nil,
                userInfo: ["deeplink": deeplink]
            )
        }
        completionHandler()
    }
}
