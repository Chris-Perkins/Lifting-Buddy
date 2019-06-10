//
//  LBWorkoutsViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/5/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints
import MagazineLayout
import Realm
import RealmSwift

/// The View Controller that shows all of the workouts that a user has available to them.
///
/// This View controller assumes that it is under a Navigation Controller.
final internal class LBWorkoutsViewController: UIViewController {

    /// Defines the insets that are used as the insets for the collection view.
    fileprivate static let collectionViewInsets = UIEdgeInsets(top: 24,  left: 18, bottom: 24, right: 18)

    /// `collectionViewWidthHeightRatio` is the ratio that is used to retrieve the height of a cell given its width.
    ///
    /// E.g.: The height of the cell is equal to `collectionViewCell.width * collectionViewCellWidthHeightRatio`
    fileprivate static let collectionViewCellWidthHeightRatio: CGFloat = 1

    /// `spacingAmount` defines the amount of vertical and horizontal spacing there should be between cells
    fileprivate static let spacingAmount: CGFloat = 12

    /// `requiredWidthPerCell` specifies the amount of width that each cell MUST have to be displayed properly.
    private static var requiredWidthPerCell: CGFloat = 160.0

    /// The Collection View where Workouts are shown.
    ///
    /// On initialization:
    ///     * Instantiated with LBReusableWorkoutIconCell being registered with the reuse identifier relating to its
    /// description property
    ///     * Database and DataSource are assigned to `self` on initialization.
    public private(set) lazy var collectionView: UICollectionView = {
        let layout = MagazineLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LBReusableWorkoutIconCell.self,
                                forCellWithReuseIdentifier: LBReusableWorkoutIconCell.description())
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()

    /// `collectionViewCellWidthRatioDivisor` is the ratio divisor that is used to retrieve the width of the collection
    /// view cells.
    ///
    /// The returned values depend on the width of the collection view. There will be one additional divisor point per
    /// 360 pixels in `selectedClipsCollection`'s width (minimum of 1).
    ///
    /// E.g.: The width of the cell is equal to `collectionView.width * (1.0 / divisor)`
    fileprivate var collectionViewCellWidthRatioDivisor: UInt {
        let collectionWidth = collectionView.frame.width

        // If you're interested in knowing how this came to be, reach out to me for the analysis.
        let collectionInsetTotalWidth =
            LBWorkoutsViewController.collectionViewInsets.left + LBWorkoutsViewController.collectionViewInsets.right
        let numberOfCellsPossible =
            (collectionWidth - collectionInsetTotalWidth + LBWorkoutsViewController.spacingAmount)
                / (LBWorkoutsViewController.spacingAmount + LBWorkoutsViewController.requiredWidthPerCell)
        // There should be at least one cell though.
        return max(1, UInt(numberOfCellsPossible))
    }

    // Note: Safe to force-cast here as Realm was already instantiated on App Startup.
    /// The realm instance that is used to retrieve stored information in the app.
    private let realmInstance = try! Realm()


    /// Initializes an LBWorkoutsViewController with the provided nibName or bundle. Both optional. Adds this
    /// LBWorkoutsViewController to the theme host.
    ///
    /// - Parameters:
    ///   - nibNameOrNil: The nib name; optional
    ///   - nibBundleOrNil: The nib bundle; optional
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        addToThemeHost()
    }

    /// Initializes an LBWorkoutsViewController from the provided NSCoder. Adds this LBWorkoutsViewController to the
    /// theme host.
    ///
    /// - Parameter aDecoder: The NSCoder to initialize with
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
    }

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
        workoutIconCell.contentView.frame = workoutIconCell.bounds
        return workoutIconCell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Extension

extension LBWorkoutsViewController: UICollectionViewDelegateMagazineLayout {

    /// Retrieves the size mode for the cell at the specified index path. This will be a size mode that corresponds to
    /// a square for each cell.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to get the size of the cell for
    ///   - collectionViewLayout: The layout of the collection view
    ///   - indexPath: The index path of the cell to get the size for
    /// - Returns: The size mode of the cell - will display as a square.
    ///
    /// This will always return a size that conforms to the specified variable of
    /// `LBWorkoutsViewController.requiredWidthPerCell` (but at least 1 cell will always be visible).
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeModeForItemAt indexPath: IndexPath) -> MagazineLayoutItemSizeMode {
        let widthMode = MagazineLayoutItemWidthMode.fractionalWidth(divisor:
            collectionViewCellWidthRatioDivisor)
        // Retrieves the height as a ratio of the width according to our input variables
        let heightMode = MagazineLayoutItemHeightMode.static(height: getWidthOfCell()
            * LBWorkoutsViewController.collectionViewCellWidthHeightRatio)
        return MagazineLayoutItemSizeMode(widthMode: widthMode, heightMode: heightMode)
    }

    /// Returns the visibility mode for the header-- which is always hidden as we don't have headers.
    ///
    /// - Parameters:
    ///   - collectionView: input
    ///   - collectionViewLayout: input
    ///   - index: input
    /// - Returns: .hidden
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        visibilityModeForHeaderInSectionAtIndex index: Int) -> MagazineLayoutHeaderVisibilityMode {
        return .hidden
    }

    /// Returns the visibility mode for the footer-- which is always hidden as we don't have footers.
    ///
    /// - Parameters:
    ///   - collectionView: input
    ///   - collectionViewLayout: input
    ///   - index: input
    /// - Returns: .hidden
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        visibilityModeForFooterInSectionAtIndex index: Int) -> MagazineLayoutFooterVisibilityMode {
        return .hidden
    }

    /// Returns the visibility mode for the background of each section-- which is always hidden as we don't have
    /// backgrounds per section.
    ///
    /// - Parameters:
    ///   - collectionView: input
    ///   - collectionViewLayout: input
    ///   - index: input
    /// - Returns: .hidden
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        visibilityModeForBackgroundInSectionAtIndex index: Int)
        -> MagazineLayoutBackgroundVisibilityMode {
            return .hidden
    }

    /// Retrieves the amount of horizontal spacing that should occur between items.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view
    ///   - collectionViewLayout: The layout of the collection view
    ///   - index: The index of the item to get the spacing for
    /// - Returns: The amount of horizontal spacing -- 12.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        horizontalSpacingForItemsInSectionAtIndex index: Int) -> CGFloat {
        return LBWorkoutsViewController.spacingAmount
    }

    /// Retrieves the amount of vertical spacing that should occur between items.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view
    ///   - collectionViewLayout: The layout of the collection view
    ///   - index: The index of the item to get the spacing for
    /// - Returns: The amount of vertical spacing -- 12.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        verticalSpacingForElementsInSectionAtIndex index: Int) -> CGFloat {
        return LBWorkoutsViewController.spacingAmount
    }

    /// Returns the insets of the section specified.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view to get the insets of the section for
    ///   - collectionViewLayout: The layout of the collection view
    ///   - index: The index of the section
    /// - Returns: The collection view insets as specified by `LBWorkoutsViewController.collectionViewInsets`
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetsForSectionAtIndex index: Int) -> UIEdgeInsets {
        return LBWorkoutsViewController.collectionViewInsets
    }

    /// Returns the insets of the items at the specified section index. This will be `.zero` since insets are not
    /// per-item.
    ///
    /// - Parameters:
    ///   - collectionView: The collection view containing the item to get the insets for
    ///   - collectionViewLayout: The layout of the collection view
    ///   - index: The index of the section
    /// - Returns: `.zero` since items should not have their own insets.
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetsForItemsInSectionAtIndex index: Int) -> UIEdgeInsets {
        return .zero
    }

    /// Gets the width that a cell would take up in this View Controller given some assumptions:
    /// 1. The spacing amount between cells
    /// 1. The width of the collection view
    /// 1. The number of cells in the collection view
    ///
    /// - Returns: The width that a cell takes up.
    private func getWidthOfCell() -> CGFloat {
        let collectionInsetTotalWidth =
            LBWorkoutsViewController.collectionViewInsets.left + LBWorkoutsViewController.collectionViewInsets.right
        return ((collectionView.frame.width - collectionInsetTotalWidth + LBWorkoutsViewController.spacingAmount)
            / CGFloat(collectionViewCellWidthRatioDivisor)) - LBWorkoutsViewController.spacingAmount
    }
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
