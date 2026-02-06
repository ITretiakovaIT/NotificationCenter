//
//  LikesViewModel.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class LikesViewModel {
    
    private var likesService: LikesService
    private let debugService: LikesDebugService?
    private let timerService: UnblurTimerService
    
    private var nextCursor: LikesCursor?
    private var isLoadingItems = false
    private var isEndReached = false
    
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
    
    var canSimulateUpdates: Bool {
        debugService != nil
    }
    
    var onItemsUpdated: (() -> Void)?
    var onTimerTick: ((TimeInterval) -> Void)?
    var onTimerFinished: (() -> Void)?
    
    init(timerService: UnblurTimerService, likesService: LikesService) {
        self.timerService = timerService
        self.likesService = likesService
        self.debugService = likesService as? LikesDebugService
        
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
        guard !isLoadingItems, !isEndReached else { return }
        
        isLoadingItems = true
        
        Task {
            let page = try await likesService.fetchLikes(
                after: nextCursor
            )
            
            print("FETCH after:", nextCursor as Any)
            print("RECEIVED:", page.items.map { $0.createdAt.toHourMinuteString() })
            print("NEXT CURSOR:", page.nextCursor as Any)
            
            await MainActor.run {
                items.append(contentsOf: page.items)
                nextCursor = page.nextCursor
                
                if page.nextCursor == nil {
                    isEndReached = true
                }
                
                isLoadingItems = false
            }
        }
    }
    
    func item(at index: Int) -> LikeItem {
        items[index]
    }
    
    func insertRandom() {
        debugService?.simulateInsert()
    }

    func removeRandom() {
        guard let item = items.randomElement() else { return }
        
        debugService?.simulateRemove(id: item.id)
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
                // If pagination is finished, the list represents a full snapshot.
                // Any new insert is treated as a genuinely new item.
                if isEndReached {
                    items.insert(item, at: min(index, items.count))
                    return
                }
                
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
