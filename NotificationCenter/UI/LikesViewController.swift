//
//  LikesViewController.swift
//  NotificationCenter
//
//  Created by Ira Tretiakova on 14.01.2026.
//

import UIKit

final class LikesViewController: UIViewController, UICollectionViewDelegate {
    
    private let viewModel: LikesViewModel
    
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
        collectionView.reloadData()
    }
    
    func checkDebugState() {
        let isHidden = !viewModel.canSimulateUpdates
        removeRandomButton.isHidden = isHidden
        insertRandomButton.isHidden = isHidden
    }
}

// MARK: Binding
private extension LikesViewController {
    func bindViewModel() {
        viewModel.onItemsUpdated = { [weak self] in
            DispatchQueue.runOnMain {
                self?.syncBlurState()
            }
        }
        
        viewModel.onTimerTick = { [weak self] remainingTime in
            DispatchQueue.runOnMain {
                self?.timerLabel.text = remainingTime.toMinuteSecondString
            }
        }
        
        viewModel.onTimerFinished = { [weak self] in
            DispatchQueue.runOnMain {
                self?.syncBlurState()
            }
        }
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
        cell.configure(user: item.user, isBlurred: !viewModel.isUnblurActive)
        
        return cell
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
