//
//  LikesViewController.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import UIKit

final class LikesViewController: UIViewController, UICollectionViewDelegate {
    
    private let viewModel: LikesViewModel
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    private var cellRegistration: UICollectionView.CellRegistration<LikeUserCell, String>!
    
    @IBOutlet private weak var unblurAllButton: UIButton!
    @IBOutlet private weak var removeRandomButton: UIButton!
    @IBOutlet private weak var insertRandomButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
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
        setupDataSource()
        registerCell()
        collectionView.contentInsetAdjustmentBehavior = .never
        
        bindViewModel()
        viewModel.onViewDidLoad()
        
        syncBlurState()
        checkDebugState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel.onViewWillAppear()
        syncBlurState()
    }
    
    @IBAction func unblurAllTapped() {
        viewModel.unblurAll()
        syncBlurState()
    }
    
    @IBAction func insertRandomTapped() {
        viewModel.insertRandom()
    }
    
    @IBAction func removeRandomTapped() {
        viewModel.removeRandom()
    }
}

// MARK: UI Helpers
private extension LikesViewController {
    func syncBlurState() {
        unblurAllButton.isHidden = viewModel.isUnblurActive
        
        collectionView.visibleCells
            .compactMap { $0 as? LikeUserCell }
            .forEach { $0.setBlurred(!viewModel.isUnblurActive)}
    }
    
    func checkDebugState() {
        let isHidden = !viewModel.canSimulateUpdates
        removeRandomButton.isHidden = isHidden
        insertRandomButton.isHidden = isHidden
    }
    
    func needsMoreContent() -> Bool {
        collectionView.layoutIfNeeded()
        return collectionView.contentSize.height <= collectionView.bounds.height
    }
}

// MARK: Binding
private extension LikesViewController {
    func bindViewModel() {
        viewModel.onItemsUpdated = { [weak self] in
            DispatchQueue.runOnMain {
                guard let self else { return }
                
                self.syncBlurState()
                
                self.applySnapshot()
                
                if self.needsMoreContent() {
                    self.viewModel.loadNext()
                }
            }
        }
        
        viewModel.onTimerTick = { [weak self] remainingTime in
            DispatchQueue.runOnMain {
                self?.timerLabel.text = remainingTime.toMinuteSecondString
                self?.syncBlurState()
            }
        }
        
        viewModel.onTimerFinished = { [weak self] in
            DispatchQueue.runOnMain {
                self?.syncBlurState()
            }
        }
        
        viewModel.onMatch = { [weak self] item in
            DispatchQueue.runOnMain {
                let alert = UIAlertController(
                    title: "It's a match!",
                    message: "You and \(item.user.name) liked each other",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

// MARK: Collection View setup
private extension LikesViewController {
    func setupCollectionView() {
        collectionView.delegate = self
    }
    
    func registerCell() {
        cellRegistration = UICollectionView.CellRegistration<LikeUserCell, String>(
            cellNib: UINib(nibName: LikeUserCell.nibName, bundle: nil)
        ) { [weak self] cell, indexPath, itemID in
            
            guard let self else { return }
            
            let item = self.viewModel.item(by: itemID)

            cell.configure(
                user: item.user,
                isBlurred: !self.viewModel.isUnblurActive
            )

            cell.onLikeTapped = { [weak self] in
                self?.viewModel.like(item: item)
            }

            cell.onSkipTapped = { [weak self] in
                self?.viewModel.skip(item: item)
            }
        }
    }
}

// MARK: Collection View DataSource
private extension LikesViewController {
    func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Int, String>(
            collectionView: collectionView
        ) { [weak self]
            (collectionView: UICollectionView,
             indexPath: IndexPath,
             itemID: String) -> UICollectionViewCell in
            
            guard let self else { return UICollectionViewCell() }
            
            return collectionView.dequeueConfiguredReusableCell(
                using: self.cellRegistration,
                for: indexPath,
                item: itemID
            )
        }
    }
    
    private func applySnapshot(animated: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(viewModel.items.map(\.id))

        dataSource.apply(snapshot, animatingDifferences: animated)
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
        cell.configure(user: item.user, isBlurred: !viewModel.isUnblurActive)
        
        cell.onLikeTapped = { [weak self] in
            self?.viewModel.like(item: item)
        }
        
        cell.onSkipTapped = { [weak self] in
            self?.viewModel.skip(item: item)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? LikeUserCell else { return }
        cell.setBlurred(!viewModel.isUnblurActive)
    }
}

extension LikesViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height

        if offset > contentHeight - height * 1.5 {
            viewModel.loadNext()
        }
    }
}
