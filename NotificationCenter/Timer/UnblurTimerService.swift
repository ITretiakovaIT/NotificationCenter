import Foundation

final class UnblurTimerService {
    
    // MARK: - Persistence
    
    private let defaults = UserDefaults.standard
    private let endDateKey = "unblurEndDate"
    
    // MARK: - Timer
    
    private var timer: DispatchSourceTimer?
    private let timerQueue = DispatchQueue(label: "unblur.timer.queue")
    
    // MARK: - Callbacks
    
    var onTick: ((TimeInterval) -> Void)?
    var onFinished: (() -> Void)?
    
    // MARK: - State
    
    var remainingTime: TimeInterval {
        max(0, endDate.timeIntervalSinceNow)
    }
    
    var isActive: Bool {
        remainingTime > 0
    }
    
    // MARK: - Public API
    
    func start(duration: TimeInterval) {
        endDate = Date().addingTimeInterval(duration)
        startTimerIfNeeded()
        notifyTick()
    }
    
    func resumeIfNeeded() {
        if remainingTime > 0 {
            startTimerIfNeeded()
            notifyTick()
        } else {
            finish()
        }
    }
    
    func stop() {
        cancelTimer()
    }
    
    func reset() {
        cancelTimer()
        clearEndDate()
    }
}

// MARK: - Private
    
private extension UnblurTimerService {
    
    var endDate: Date {
        get {
            defaults.object(forKey: endDateKey) as? Date ?? .distantPast
        }
        set {
            defaults.set(newValue, forKey: endDateKey)
        }
    }
    
    func startTimerIfNeeded() {
        guard timer == nil else { return }
        
        let timer = DispatchSource.makeTimerSource(queue: timerQueue)
        timer.schedule(deadline: .now(), repeating: 1)
        
        timer.setEventHandler { [weak self] in
            self?.tick()
        }
        
        timer.resume()
        self.timer = timer
    }
    
    func cancelTimer() {
        timer?.cancel()
        timer = nil
    }
    
    func tick() {
        let remaining = remainingTime

        if remaining <= 0 {
            DispatchQueue.runOnMain { [weak self] in
                self?.finish()
            }
        } else {
            DispatchQueue.runOnMain { [weak self] in
                self?.onTick?(remaining)
            }
        }
    }
    
    func notifyTick() {
        let remaining = remainingTime
        onTick?(remaining)
    }

    func finish() {
        cancelTimer()
        clearEndDate()
        onFinished?()
    }

    func clearEndDate() {
        defaults.removeObject(forKey: endDateKey)
    }
}
