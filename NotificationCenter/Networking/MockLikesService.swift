//
//  MockLikesService.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class MockLikesService: LikesService {
    
    var onUpdate: ((LikesUpdate) -> Void)?
    
    private let pageSize = 10
    
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
    
    func simulateInsert(_ item: LikeItem) {
        // знаходимо позицію за createdAt
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
        allItems = (1...35).map {
            LikeItem(
                id: "\($0)",
                user: User(id: "\($0)",
                           name: ["Alex", "Max", "John", "Luka", "Kurt", "James"].randomElement()!,
                           avatarURL: URL(string: "asset://avatar\(["1", "2", "3", "4", "5", "6"].randomElement()!)")),
                createdAt: Date()
            )
        }

        allItems.sort { $0.createdAt > $1.createdAt }
    }
}
