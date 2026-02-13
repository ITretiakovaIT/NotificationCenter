//
//  LikeItem.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

struct LikeItem: Identifiable, Equatable, Hashable {
    let id: String
    let user: User
    let createdAt: Date
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LikeItem, rhs: LikeItem) -> Bool {
        lhs.id == rhs.id
    }
}
