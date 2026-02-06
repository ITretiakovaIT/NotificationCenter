//
//  User.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

struct User: Equatable {
    let id: UUID
    let name: String
    let avatarURL: URL?
}

extension User {

    static func random() -> User {
        User(
            id: UUID(),
            name: names.randomElement()!,
            avatarURL: URL(string: "asset://avatar\(avatars.randomElement()!)")
        )
    }

    private static let names = ["Alex", "Max", "John", "Luka", "Kurt", "James"]
    private static let avatars = ["1", "2", "3", "4", "5", "6"]
}
