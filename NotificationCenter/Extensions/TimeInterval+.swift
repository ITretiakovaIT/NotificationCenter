//
//  TimeInterval+.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 06.02.2026.
//

import Foundation

extension TimeInterval {

    /// Formats the time interval into "mm:ss" format.
    /// Useful for countdown timers and UI labels.
    var toMinuteSecondString: String {
        let totalSeconds = max(0, Int(self))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
