//
//  UnblurTimerService.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class UnblurTimerService {
    
    private let defaults = UserDefaults.standard
    private let endDateKey = "unblurEndDate"
    
    private var timer: Timer?
    
    var onTick: ((TimeInterval) -> Void)?
    var onFinished: (() -> Void)?
    
    var remainingTime: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }
    
    var isActive: Bool {
        remainingTime>0
    }
    
    func start(duration: TimeInterval) {
        endDate = Date().addingTimeInterval(duration)
        startTimer()
    }
    
    func resumeIfNeeded() {
        if remainingTime > 0 {
            startTimer()
        } else {
            stop()
            onFinished?()
            reset()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func reset() {
        UserDefaults.standard.removeObject(forKey: endDateKey)
    }
}

private extension UnblurTimerService {
    private var endDate: Date {
        get {
            defaults.object(forKey: endDateKey) as? Date ?? .distantPast
        }
        set {
            defaults.set(newValue, forKey: endDateKey)
        }
    }

    private func startTimer() {
        stop()

        timer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        let remaining = remainingTime

        if remaining <= 0 {
            stop()
            onFinished?()
        } else {
            onTick?(remaining)
        }
    }
}
