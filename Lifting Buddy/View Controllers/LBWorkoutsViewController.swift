//
//  LBWorkoutsViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/5/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints
import Realm
import RealmSwift

/// The View Controller that shows all of the workouts that a user has available to them.
///
/// This View controller assumes that it is under a Navigation Controller.
final internal class LBWorkoutsViewController: UIViewController {

    /// Defines the insets that are used as the insets for the collection view.
    fileprivate static let collectionViewInsets = UIEdgeInsets(top: 24,  left: 12, bottom: 24, right: 12)

    // Note: Safe to force-cast here as Realm was already instantiated on App Startup.
    /// The realm instance that is used to retrieve stored information in the app.
    private let realmInstance = try! Realm()

    /// The Collection View where Workouts are shown.
    ///
    /// On initialization:
    ///     * Instantiated with LBReusableWorkoutIconCell being registered with the reuse identifier relating to its
    /// description property
    ///     * Database and DataSource are assigned to `self` on initialization.
    public private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = CGSize(width: 20, height: 100)
        layout.itemSize = CGSize(width: 20, height: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(LBReusableWorkoutIconCell.self,
                                forCellWithReuseIdentifier: LBReusableWorkoutIconCell.description())
        collectionView.contentInset = LBWorkoutsViewController.collectionViewInsets
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    /// Called when the view loads. Causes the views to layout themselves out via constraints.
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviewsLayout()
    }

    /// Causes the views to lay themselves out accordingly.
    ///
    /// The layout is as follows:
    /// 1. Collection View
    ///     * Fill this view
    ///
    /// - Warning: This assumes `view` is non-nil.
    private func setupSubviewsLayout() {
        view.addSubview(collectionView)
        collectionView.copy(.left, .right, .top, .bottom, of: view)
    }
}

// MARK: - UICollectionViewDataSource Extension

extension LBWorkoutsViewController: UICollectionViewDataSource {

    /// Returns the number of items to be placed in the provided collection view. The collection view is guaranteed to
    /// be instance member `collectionView`.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to get the number of items for
    ///   - section: The section to get the number of items for
    /// - Returns: The number of workouts to display in the collection view.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return realmInstance.objects(Workout.self).count
    }

    /// Returns the cell to display in the collection view. The collection view paramter is guaranteed to be instance
    /// member `collectionView`.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view item to get cell item for
    ///   - indexPath: The index path to get the cell for
    /// - Returns: The collection view cell layout so that it matches the workout at the provided row of the index path
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let workout = realmInstance.objects(Workout.self)[indexPath.row]
        let dequeuedCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: LBReusableWorkoutIconCell.description(),
                                               for: indexPath)
        guard let workoutIconCell = dequeuedCell as? LBReusableWorkoutIconCell else {
            print("Expected the dequeued cell to be of type [\(LBReusableWorkoutIconCell.self)], but was of type"
                + "\(dequeuedCell.self)")
            return dequeuedCell
        }
        workoutIconCell.cellTitle.text = workout.getName()
        workoutIconCell.streakLabel.text = String(describing: workout.getCurSteak())
        return workoutIconCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Extension

extension LBWorkoutsViewController: UICollectionViewDelegateFlowLayout {

    /// Returns the size of the cell at the provided index. Currently set to 20, 20 for debug purposes.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to retrieve the size of the cell for
    ///   - collectionViewLayout: The layout applied to the collection view
    ///   - indexPath: The IndexPath of the item to get the size for in `collectionView`
    /// - Returns: A Size of 20, 20
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 20, height: 20)
    }
}

// MARK: - UICollectionViewDelegate Extension

extension LBWorkoutsViewController: UICollectionViewDelegate {
}

// MARK: - ThemeColorableElement Extension

extension LBWorkoutsViewController: ThemeColorableElement {

    /// Colors the tab bar such that it is Lifting Buddy style themed with the parameter theme.
    ///
    /// - Parameter colorProvider: The provider of the theme colors.
    ///
    /// Colors the elements as follows:
    /// * view.backgroundColor - Use the primary color's main variant
    func color(using colorProvider: ThemeColorProvider) {
        view.backgroundColor = colorProvider.getPrimaryColor(variant: .mainElement)
    }
}
