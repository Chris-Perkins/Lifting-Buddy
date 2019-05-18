//
//  SettingsViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/5/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit
import GBVersionTracking

class SettingsViewController: UIViewController {
    
    // MARK: View Controller Properties
    
    // Gets placed under the status bar
    let headerView = UIView()
    // Displays the title of this view
    let titleLabel = UILabel()
    // The view which holds all information views
    let contentView = SettingsContentView()
    // Closes the view
    let closeButton = PrettyButton()
    
    // MARK: View Controller overrides
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch (activeColorScheme) {
        case .light:
            return .default
        case .dark:
            return .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(headerView)
        view.addSubview(contentView)
        view.addSubview(closeButton)
        
        headerView.addSubview(titleLabel)
        
        closeButton.addTarget(self, action: #selector(buttonPress(button:)), for: .touchUpInside)
        
        createAndActivatHeaderViewConstraints()
        createAndActivateTitleLabelConstraints()
        createAndActivateCloseButtonConstraints()
        
        createAndActivateContentViewConstraints()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // View Controller
        setNeedsStatusBarAppearanceUpdate()
        
        // View
        view.backgroundColor = .lightBlackWhiteColor

        // HeaderView
        headerView.backgroundColor = .primaryBlackWhiteColor
        
        // TitleLabel
        titleLabel.setDefaultProperties()
        titleLabel.textColor       = UILabel.titleLabelTextColor
        titleLabel.text            = NSLocalizedString("Info.AppName", comment: "") + " v\(GBVersionTracking.currentVersion()!)"
        
        // CloseButton
        closeButton.setDefaultProperties()
        closeButton.setTitle(NSLocalizedString("Button.Close", comment: ""), for: .normal)
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(button: PrettyButton) {
        switch button {
        case closeButton:
            performBackSegue()
        default:
            fatalError("Button pressed but not set up!")
        }
    }
    
    // MARK: Custom functions
    
    // Returns to the calling view controller
    private func performBackSegue() {
        performSegue(withIdentifier: "exitSegue", sender: self)
    }
    
    // MARK: Constraints
    
    // Cling to left, top, right of view ; height of status bar + title label
    private func createAndActivatHeaderViewConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: view,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: view,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: headerView,
                                                             withCopyView: view,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: headerView,
                                                         height: statusBarHeight +
                                                                UILabel.titleLabelHeight).isActive = true
    }
    
    // Cling to left right of headerView ; height of title default
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .top,
                                                             plusConstant: statusBarHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: headerView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: UILabel.titleLabelHeight).isActive = true
    }
    
    // Cling to left, bottom, right of view ; height of default
    private func createAndActivateCloseButtonConstraints() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: view,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: view,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: closeButton,
                                                             withCopyView: view,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: closeButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
    
    // Below headerview ; cling to left, right of view ; place above closeButton
    private func createAndActivateContentViewConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: contentView,
                                                         belowView: headerView).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: view,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: view,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: closeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
