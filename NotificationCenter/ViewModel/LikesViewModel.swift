//
//  LikesViewModel.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class LikesViewModel {
    
    private let likesService: LikesService
    private let timerService: UnblurTimerService
    
    private(set) var items: [LikeItem] = []{
        didSet {
            onItemsUpdated?()
        }
    }
    
    var isUnblurActive: Bool {
        timerService.isActive
    }
    
    var onItemsUpdated: (() -> Void)?
    var onTimerTick: ((TimeInterval) -> Void)?
    var onTimerFinished: (() -> Void)?
    
    init(timerService: UnblurTimerService, likesService: LikesService) {
        self.timerService = timerService
        self.likesService = likesService
        
        bindTimer()
    }
    
    func onViewDidLoad() {
        loadInitial()
        timerService.resumeIfNeeded()
    }
    
    func onViewWillAppear() {
        timerService.resumeIfNeeded()
    }
    
    func unblurAll() {
        timerService.start(duration: 15)
    }
    
    func loadNextPage() {
        // pagination
    }
    
    var numberOfItems: Int {
        items.count
    }
    
    func item(at index: Int) -> LikeItem {
        items[index]
    }
}

private extension LikesViewModel {
    func loadInitial() {
        Task {
            do {
                let result = try await likesService.fetchLikes(page: 1)
                await MainActor.run {
                    self.items = result
                }
            } catch {
                print("Erorr fetch items: \(error)")
            }
        }
    }
    
    func bindTimer() {
        timerService.onTick = { [weak self] time in
            self?.onTimerTick?(time)
        }
        
        timerService.onFinished = { [weak self] in
            self?.onTimerFinished?()
        }
    }
}
