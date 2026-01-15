//
//  LikesViewModel.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

final class LikesViewModel {

    private(set) var items: [LikeItem] = []

    init() {
        items = [
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
            )
        ]
    }

    var numberOfItems: Int {
        items.count
    }

    func item(at index: Int) -> LikeItem {
        items[index]
    }
}
