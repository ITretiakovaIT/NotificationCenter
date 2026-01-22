//
//  LikesViewController.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import UIKit

final class LikesViewController: UIViewController, UICollectionViewDelegate {
    
    private let viewModel: LikesViewModel
    
    private var refreshTimer: Timer?
    
    @IBOutlet private weak var unblurAllButton: UIButton!
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
        collectionView.contentInsetAdjustmentBehavior = .never
        
        viewModel.onItemsUpdated = { [weak self] in
            self?.collectionView.reloadData()
        }
        
        viewModel.loadInitial()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.refreshStateIfNeeded()
        collectionView.reloadData()

        startRefreshTimerIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRefreshTimer()
    }
    
    @IBAction func unblurAllTapped() {
        viewModel.unblurAll()
        unblurAllButton.isHidden = true
        collectionView.reloadData()
    }
}

// MARK: Timer
private extension LikesViewController {
    func startRefreshTimerIfNeeded() {
        guard viewModel.isBlurred else { return }

        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: 1,
            repeats: true
        ) { [weak self] _ in
            guard let self else { return }

            if !self.viewModel.isBlurred {
                self.stopRefreshTimer()
                self.collectionView.reloadData()
            }
        }
    }
    
    private func stopRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
}

// MARK: Collection View setup
private extension LikesViewController {
    func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(
            UINib(nibName: LikeUserCell.nibName, bundle: nil),
            forCellWithReuseIdentifier: LikeUserCell.reuseIdentifier
        )
    }
}

// MARK: Collection View Flow Layout
extension LikesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        let spacing: CGFloat = 8
        let totalSpacing = spacing * 3 // left + right + між колонками
        let width = (collectionView.bounds.width - totalSpacing) / 2
        let height = width * 1.4

        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        8
    }
}

// MARK: Collection View Data Source
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
        cell.configure(user: item.user, isBlurred: viewModel.isBlurred)
        
        return cell
    }
}
