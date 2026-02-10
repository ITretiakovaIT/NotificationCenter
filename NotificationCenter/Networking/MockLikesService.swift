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
    
    private let factory = LikeItemFactory()
    
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
        guard !allItems.isEmpty else { return }
        
        // Pick a random existing item and insert relative to it
        let referenceIndex = Int.random(in: 0..<allItems.count)
        let referenceItem = allItems[referenceIndex]
        
        // Create a new item slightly newer than the reference one
        let createdAt = referenceItem.createdAt.addingTimeInterval(30)
        
        let item = factory.make(createdAt: createdAt)
        
        let index = allItems.firstIndex {
            $0.createdAt < item.createdAt
        } ?? allItems.count

        allItems.insert(item, at: index)
        
        print("INSERT:", item.user.name, "at index:", index)
        
        onUpdate?(.inserted(item, at: index))
    }
    
    func simulateRemove(id: String) {
        guard let index = allItems.firstIndex(where: { $0.id == id }) else { return }
        let item = allItems.remove(at: index)
        
        print("REMOVE:", item.user.name, "from index:", index)
        
        onUpdate?(.removed(id: id))
    }
}

// MARK: - Private
private extension MockLikesService {
    
    private func seed() {
        let now = Date()
        
        allItems = (1...12).map {
            factory.make(createdAt: now.addingTimeInterval(-TimeInterval($0) * 60))
        }

        allItems.sort { $0.createdAt > $1.createdAt }
    }
}
