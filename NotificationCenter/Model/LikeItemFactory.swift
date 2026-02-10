//
//  LikeItemFactory.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 10.02.2026.
//

import Foundation

final class LikeItemFactory {

    private var nextID: Int = 1

    func make(createdAt: Date) -> LikeItem {
        let id = nextID
        nextID += 1

        return LikeItem(
            id: "\(id)",
            user: User(
                id: UUID(),
                name: "User \(id)",
                avatarURL: URL(string: "asset://avatar\(id % 6 + 1)")
            ),
            createdAt: createdAt
        )
    }
}
