//
//  MockLikesService.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class MockLikesService: LikesService, LikesDebugService {
    
    var onUpdate: ((LikesUpdate) -> Void)?
    
    private let pageSize = 5
    
    private var allItems: [LikeItem] = []
    
    init() {
        seed()
    }
    
    // MARK: - Pagination
    
    func fetchLikes(
        after cursor: LikesCursor?
    ) async throws -> LikesPage {
        let filtered: [LikeItem]
        
        if let cursor {
            filtered = allItems.filter { $0.createdAt < cursor }
        } else {
            filtered = allItems
        }
        
        let pageItems = Array(filtered.prefix(pageSize))
        let nextCursor = pageItems.last?.createdAt
        
        return LikesPage(
            items: pageItems,
            nextCursor: nextCursor
        )
    }
    
    // MARK: - Real-time simulation
    
    func simulateInsert() {
        let createdAt: Date
        
        if Bool.random() {
            createdAt = Date() // new item → top
        } else {
            createdAt = Date().addingTimeInterval(-TimeInterval(Int.random(in: 60...300)))
            // older item → middle / bottom
        }
        
        let item = LikeItem.random(createdAt: createdAt)
        
        let index = allItems.firstIndex {
            $0.createdAt < item.createdAt
        } ?? allItems.count

        allItems.insert(item, at: index)
        onUpdate?(.inserted(item, at: index))
    }
    
    func simulateRemove(id: String) {
        guard let index = allItems.firstIndex(where: { $0.id == id }) else { return }
        allItems.remove(at: index)
        onUpdate?(.removed(id: id))
    }
}

// MARK: - Private
private extension MockLikesService {
    
    private func seed() {
        let now = Date()
        
        allItems = (1...12).map {
            LikeItem.random(createdAt: now.addingTimeInterval(-TimeInterval($0) * 60))
        }

        allItems.sort { $0.createdAt > $1.createdAt }
    }
    
    func makeRandomItem() -> LikeItem {
        LikeItem(
            id: UUID().uuidString,
            user: User.random(),
            createdAt: Date()
        )
    }
}
