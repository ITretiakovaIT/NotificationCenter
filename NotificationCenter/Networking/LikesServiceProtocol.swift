//
//  LikesServiceProtocol.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import Foundation

protocol LikesService {
    func fetchLikes(page: Int) async throws -> [LikeItem]
}
