//
//  NotificationHandlers.swift
//  Quotes
//
//  Created by Alon Rozmarin on 28/09/2023.
//

import Foundation
import UserNotifications

class NotificationHandler {
    func askPremmision() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            success, error in if success {
                print("Access granted!")
            }
            else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func sendNotification(quote: String, hour: Int, minute: Int) {
        var trigger: UNNotificationTrigger?
        let Components = DateComponents(hour: hour, minute: minute)

        trigger = UNCalendarNotificationTrigger(dateMatching: Components, repeats: true)
        
        let content = UNMutableNotificationContent()
        content.body = quote
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)

    }
}
