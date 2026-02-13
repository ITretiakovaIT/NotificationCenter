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
    var onMatch: ((LikeItem) -> Void)?
    
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
        timerService.start(duration: 30)
    }
    
    func loadNext() {
        guard !isLoadingItems, !isEndReached else { return }
        
        isLoadingItems = true
        
        Task {
            let page = try await likesService.fetchLikes(
                after: nextCursor
            )
            
            print("FETCH after:", nextCursor?.toHourMinuteString() ?? "")
            print("RECEIVED:", page.items.map { ($0.user.name, $0.createdAt.toHourMinuteString()) })
            print("NEXT CURSOR:", page.nextCursor?.toHourMinuteString() ?? "")
            
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
    
    func item(by id: String) -> LikeItem {
        items.first { $0.id == id }!
    }
    
    func insertRandom() {
        debugService?.simulateInsert()
    }

    func removeRandom() {
        debugService?.simulateRemove()
    }

    func skip(item: LikeItem) {
        likesService.skip(id: item.id)
    }

    func like(item: LikeItem) {
        likesService.like(id: item.id)
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
            case .matched(let item):
                onMatch?(item)
            }
        }
    }
}
