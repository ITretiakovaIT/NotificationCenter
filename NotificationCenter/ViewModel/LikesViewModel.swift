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
    
    var isBlurred: Bool {
        !timerService.isActive()
    }
    
    var onItemsUpdated: (() -> Void)?
    
    init(timerService: UnblurTimerService, likesService: LikesService) {
        self.timerService = timerService
        self.likesService = likesService
    }
    
    
    func unblurAll() {
        timerService.activate()
        // оновити state
    }
    
    func refreshStateIfNeeded() {
        // викликаємо при появі екрану
        if !timerService.isActive() {
            timerService.reset()
        }
    }
    
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
