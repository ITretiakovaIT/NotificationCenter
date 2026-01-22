//
//  UnblurTimerService.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class UnblurTimerService {

    private let storageKey = "unblur_end_date"
    private let duration: TimeInterval = 2 * 60

    func activate() {
        let endDate = Date().addingTimeInterval(duration)
        UserDefaults.standard.set(endDate, forKey: storageKey)
    }

    func isActive() -> Bool {
        guard let endDate = UserDefaults.standard.object(forKey: storageKey) as? Date else {
            return false
        }
        return Date() < endDate
    }

    func remainingTime() -> TimeInterval {
        guard let endDate = UserDefaults.standard.object(forKey: storageKey) as? Date else {
            return 0
        }
        return max(0, endDate.timeIntervalSinceNow)
    }

    func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
