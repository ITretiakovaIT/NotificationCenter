//
//  MockLikesService.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class MockLikesService: LikesService {
    func fetchLikes(page: Int) async throws -> [LikeItem] {
        [
            LikeItem(
                id: .init(),
                user: User(id: "1", name: "Alex", avatarURL: URL(string: "asset://avatar1"))
            ),
            LikeItem(
                id: .init(),
                user: User(id: "2", name: "Max", avatarURL: URL(string: "asset://avatar2"))
            ),
            LikeItem(
                id: .init(),
                user: User(id: "3", name: "John", avatarURL: URL(string: "asset://avatar3"))
            ),
            LikeItem(
                id: .init(),
                user: User(id: "4", name: "Alex", avatarURL: URL(string: "asset://avatar4"))
            ),
            LikeItem(
                id: .init(),
                user: User(id: "5", name: "Max", avatarURL: URL(string: "asset://avatar5"))
            ),
            LikeItem(
                id: .init(),
                user: User(id: "6", name: "John", avatarURL: URL(string: "asset://avatar6"))
            )
        ]
    }
}
