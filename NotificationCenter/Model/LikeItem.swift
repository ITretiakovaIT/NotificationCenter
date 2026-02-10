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
