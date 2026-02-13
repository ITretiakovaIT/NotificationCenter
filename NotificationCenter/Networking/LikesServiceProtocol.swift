//
//  LikesServiceProtocol.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

struct LikesPage {
    let items: [LikeItem]
    let nextCursor: LikesCursor?
}

enum LikesUpdate {
    case inserted(LikeItem, at: Int)
    case removed(id: String)
    case matched(LikeItem)
}

typealias LikesCursor = Date

protocol LikesService {
    func fetchLikes(after cursor: LikesCursor?) async throws -> LikesPage

    func skip(id: String)
    func like(id: String)
    
    var onUpdate: ((LikesUpdate) -> Void)? { get set }
}

protocol LikesDebugService {
    func simulateInsert()
    func simulateRemove()
}
