//
//  LikeCollectionViewCell.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 15.01.2026.
//

import UIKit

class LikeUserCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: LikeUserCell.self)
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var likeButoon: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(user: User, isBlurred: Bool) {
        // тимчасово
//        textLabel?.text = user.name
        userNameLabel.text = user.name
        
        if
            let url = user.avatarURL,
            url.scheme == "asset",
            let imageName = url.host {
            avatarImageView.image = UIImage(named: imageName)
        }
    }

}
