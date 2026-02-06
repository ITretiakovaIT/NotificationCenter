//
//  Date+.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 06.02.2026.
//

import Foundation

extension Date {

    /// Formats the date into a "HH:mm" string (24-hour format).
    /// The DateFormatter is created once because it is expensive to initialize.
    func toHourMinuteString() -> String {
        return Date.hourMinuteFormatter.string(from: self)
    }

    private static let hourMinuteFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = .current
        formatter.timeZone = .current
        return formatter
    }()
}
