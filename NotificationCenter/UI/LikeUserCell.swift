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
    
    private var isBlurred: Bool = true
    
    var onLikeTapped: (() -> Void)?
    var onSkipTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blurView.isHidden = true
        onLikeTapped = nil
        onSkipTapped = nil
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        onLikeTapped?()
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        onSkipTapped?()
    }
    
    func configure(user: User, isBlurred: Bool) {
        userNameLabel.text = user.name
        setBlurred(isBlurred)
        avatarImageView.setImage(from: user.avatarURL)
    }

    func setBlurred(_ blurred: Bool) {
        guard isBlurred != blurred else { return }
        isBlurred = blurred
        blurView.isHidden = !isBlurred
    }
}
