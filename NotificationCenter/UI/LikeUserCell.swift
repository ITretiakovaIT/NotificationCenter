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
    @IBOutlet private weak var blurView: UIVisualEffectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blurView.isHidden = true
    }
    
    func configure(user: User, isBlurred: Bool) {
        userNameLabel.text = user.name
        blurView.isHidden = !isBlurred
        avatarImageView.setImage(from: user.avatarURL)
    }

}
