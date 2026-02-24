//
//  NotificationManager.swift
//  Lynk
//
//  Created by gülçin çetin on 24.02.2026.
//

import UserNotifications
import Foundation

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    // Set the delegate so notifications show even if the app is open
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted.")
            } else if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    // NEW: Schedules a reminder a specific number of hours BEFORE the event
    func scheduleEarlyReminder(title: String, body: String, targetDate: Date, hoursBefore: Int = 24) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Subtract the hours from the target date
        guard let reminderDate = Calendar.current.date(byAdding: .hour, value: -hoursBefore, to: targetDate) else { return }
        
        // If the calculated reminder time is already in the past, don't schedule it
        if reminderDate < Date() { return }
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Use a unique ID so we don't overwrite other alarms
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    // Forces the notification banner to drop down even if the user is looking at the app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
