//
//  LikesCoordinator.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import UIKit

final class LikesCoordinator {

    func start() -> UIViewController {
        let viewModel = LikesViewModel()
        let viewController = LikesViewController(viewModel: viewModel)
        return viewController
    }
}
