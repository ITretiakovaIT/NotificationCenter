//
//  UIImageView+.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 16.01.2026.
//

import UIKit

extension UIImageView {
    func setImage(from assetURL: URL?) {
        guard
            let assetURL,
            assetURL.scheme == "asset",
            let imageName = assetURL.host
        else {
            image = UIImage(systemName: "person.crop.circle")
            return
        }

        image = UIImage(named: imageName)
    }
}
