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
import SwiftUI
import UIKit

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
                     deeplink: String? = nil, attachment: URL? = nil,
                     after delay: TimeInterval = 1) {
        let content = UNMutableNotificationContent()
        content.title = title
        if let subtitle { content.subtitle = subtitle }
        content.body = body
        content.sound = .default
        if let deeplink { content.userInfo = ["deeplink": deeplink] }
        if let attachment,
           let att = try? UNNotificationAttachment(identifier: "receipt", url: attachment) {
            content.attachments = [att]
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(1, delay), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }

    /// Push the `DI · Expanded (sent success / received)` receipt as a banner.
    /// Renders the actual receipt card as the notification's rich attachment so
    /// the expanded banner shows the DI card, not plain text. Taps open the wallet.
    @MainActor
    static func sendTxReceipt(_ tx: TxReceipt) {
        send(
            title: tx.title,                                   // "Sent successfully" / "Received"
            body: "\(tx.who) · \(tx.amountText) GTX  \(tx.fiatText)",
            subtitle: "GridTokenX",
            deeplink: "wallet",
            attachment: receiptImage(tx)
        )
    }

    /// Render the receipt card (`TxIslandExpanded` on the black DI canvas) to a
    /// PNG file for use as a notification attachment. Returns nil on failure.
    @MainActor
    private static func receiptImage(_ tx: TxReceipt) -> URL? {
        let card = TxIslandExpanded(tx: tx)
            .padding(EdgeInsets(top: 18, leading: 20, bottom: 18, trailing: 20))
            .frame(width: 360)
            .background(Color(hex: "#15101F"))

        let renderer = ImageRenderer(content: card)
        renderer.scale = 3
        guard let image = renderer.uiImage, let data = image.pngData() else { return nil }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("receipt-\(UUID().uuidString).png")
        do { try data.write(to: url); return url } catch { return nil }
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
