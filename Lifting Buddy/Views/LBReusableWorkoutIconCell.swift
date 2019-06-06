//
//  ReusableWorkoutIconCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 6/3/19.
//  Copyright © 2019 Christopher Perkins. All rights reserved.
//

import ClingConstraints

internal class ReusableWorkoutIconCell: UICollectionReusableView {

    /// Holds the values of the different layout-based values used in constraining the subviews of this view.
    private struct LayoutValues {

        /// The maximum multiplier for the relation between `streakImageView`'s and `self`'s height.
        static let streakImageViewSelfHeightMultiplier: CGFloat = 0.4

        /// The aspect ratio that the streakImageView should have.
        static let streakImageViewAspectRatio: CGFloat = 256 / 194

        /// The multiplier for the relation between `fakeCellView`'s and `streamImageView`'s top.
        static let fakeCellStreamImageViewRightMultiplier: CGFloat = 0.9

        /// The multiplier for the relation between `fakeCellView`'s and `streamImageView`'s right.
        static let fakeCellStreamImageViewTopMultiplier: CGFloat = 0.1

        /// Private initializer to disallow initialization.
        private init() {}
    }

    /// The label that displays the current streak count.
    public private(set) lazy var streakLabel: UILabel = {
        let streakLabel = UILabel()
        streakLabel.text = "1"
        return streakLabel
    }()

    /// The image view that shows the flame image that signifies a streak.
    public private(set) lazy var streakImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Fire")
        return imageView
    }()

    /// The title that is used to display the name of the workout.
    public private(set) lazy var cellTitle: UILabel = {
        let label = UILabel()
        label.text = "yo"
        return label
    }()

    /// The container view
    public private(set) lazy var cellImageViewContainer: UIView = {
        return UIView()
    }()

    /// The image view that gives the cell a picture-identifiable mode for displaying content.
    public private(set) lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Fire")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    /// The fake cell.
    ///
    /// This is "fake" because it is not the true cell, and only covers a portion of the space of the true space
    /// available through `self.`
    public let fakeCellView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5.0
        view.layer.shadowOffset = CGSize(width: 1, height: 1)
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        return view
    }()

    /// Initializes a reusable workout icon cell with the provided frame. Also adds to the theme host and sets up the
    /// layout of this view.
    ///
    /// - Parameter frame: The frame to initialize with.
    override init(frame: CGRect) {
        super.init(frame: frame)

        addToThemeHost()
        setupSubViewsLayout()
    }

    /// Initializes a reusable workout icon cell with the provided decoder. Also adds to the theme host and sets up the
    /// layout of this view.
    ///
    /// - Parameter aDecoder: The Decoder to initialize with.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        addToThemeHost()
        setupSubViewsLayout()
    }

    private func setupSubViewsLayout() {
        addSubview(streakImageView)
        streakImageView.addSubview(streakLabel)
        addSubview(fakeCellView)
        fakeCellView.addSubview(cellTitle)
        fakeCellView.addSubview(cellImageView)

        streakImageView.copy(.height, of: self)
            .withMultipliers(LayoutValues.streakImageViewSelfHeightMultiplier)
        streakImageView.cling(.height, to: streakImageView, .width)
            .withMultiplier(LayoutValues.streakImageViewAspectRatio)
        streakImageView.copy(.top, .right, of: self)

        streakLabel.copy(.centerX, .centerY, of: streakImageView)

        fakeCellView.copy(.bottom, .left, of: self)
        fakeCellView.cling(.top, to: streakImageView, .centerY)
        fakeCellView.copy(.right, of: streakImageView)
            .withMultipliers(LayoutValues.fakeCellStreamImageViewRightMultiplier)

        cellTitle.copy(.bottom, .left, .right, of: fakeCellView)

        cellImageView.copy(.top, .left, .right, of: fakeCellView)
        cellImageView.cling(.bottom, to: cellTitle, .top)
    }
}

// MARK: - ThemeColorableElement Extension

extension ReusableWorkoutIconCell: ThemeColorableElement {

    /// Colors this view based on the current active color scheme
    ///
    /// - Parameter colorProvider: <#colorProvider description#>
    ///
    /// TODO: Anti color based on primary accent color.
    func color(using colorProvider: ThemeColorProvider) {
        streakImageView.tintColor = colorProvider.getSecondaryAccentColor(variant: .mainElement)
        fakeCellView.backgroundColor = colorProvider.getPrimaryAccentColor(variant: .mainElement)
    }
}
