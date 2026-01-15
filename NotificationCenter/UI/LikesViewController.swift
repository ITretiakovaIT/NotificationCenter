//
//  LikesViewController.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import UIKit

final class LikesViewController: UIViewController, UICollectionViewDelegate {
    
    private let viewModel: LikesViewModel
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    init(viewModel: LikesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: String(describing: Self.nibName), bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Liked You"
        
        setupCollectionView()
    }
}

private extension LikesViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(nibName: LikeUserCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: LikeUserCell.reuseIdentifier
        )
        
        collectionView.contentInset = UIEdgeInsets(
            top: 16,
            left: 16,
            bottom: 16,
            right: 16
        )
    }
}

extension LikesViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 16
        let totalSpacing = spacing * 3 // left + right + між колонками
        let width = (collectionView.bounds.width - totalSpacing) / 2
        let height = width * 1.4

        return CGSize(width: width, height: height)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }
}

extension LikesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: LikeUserCell.reuseIdentifier,
            for: indexPath
        ) as? LikeUserCell else {
            return UICollectionViewCell()
        }
        
        let item = viewModel.item(at: indexPath.item)
        cell.configure(user: item.user, isBlurred: true)
        
        return cell
    }
}
