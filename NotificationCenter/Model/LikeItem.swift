//
//  LikeItem.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

struct LikeItem: Identifiable, Equatable {
    let id: String
    let user: User
    let createdAt: Date
}

extension LikeItem {

    static func random(createdAt: Date = Date()) -> LikeItem {
        LikeItem(
            id: UUID().uuidString,
            user: User.random(),
            createdAt: createdAt
        )
    }
}
