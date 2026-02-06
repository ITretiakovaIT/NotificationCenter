//
//  LikesViewModel.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class LikesViewModel {
    
    private var likesService: LikesService
    private let timerService: UnblurTimerService
    
    private var nextCursor: LikesCursor?
    private var isLoadingItems = false
    
    private(set) var items: [LikeItem] = []{
        didSet {
            onItemsUpdated?()
        }
    }
    
    var numberOfItems: Int {
        items.count
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
        bindUpdates()
    }
    
    func onViewDidLoad() {
        loadNext()
        timerService.resumeIfNeeded()
    }
    
    func onViewWillAppear() {
        timerService.resumeIfNeeded()
    }
    
    func unblurAll() {
        timerService.start(duration: 15)
    }
    
    func loadNext() {
        guard !isLoadingItems else { return }
        isLoadingItems = true
        
        Task {
            let page = try await likesService.fetchLikes(
                after: nextCursor
            )
            
            await MainActor.run {
                items.append(contentsOf: page.items)
                nextCursor = page.nextCursor
                isLoadingItems = false
            }
        }
    }
    
    func item(at index: Int) -> LikeItem {
        items[index]
    }
}

private extension LikesViewModel {
    
    func bindTimer() {
        timerService.onTick = { [weak self] time in
            self?.onTimerTick?(time)
        }
        
        timerService.onFinished = { [weak self] in
            self?.onTimerFinished?()
        }
    }
    
    func bindUpdates() {
        likesService.onUpdate = { [weak self] update in
            guard let self else { return }
            
            switch update {
            case .inserted(let item, let index):
                guard let nextCursor, item.createdAt > nextCursor else {
                    return
                }
                
                self.items.insert(item, at: min(index, self.items.count))
                
            case .removed(let id):
                self.items.removeAll { $0.id == id }
            }
        }
    }
}
