//
//  HeaderView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Header View shown at the top of the application at all times

import UIKit
import CDAlertView
import GBVersionTracking

class HeaderView: UIView {
    
    // MARK: View properties
    
    // Lifting Buddy's URL
    private static let appURL = URL(string: "http://chrisperkins.me/LiftingBuddy/")!
    
    // Bar below status bar
    private let contentView: UIView
    // Bar that displays title of app
    private let titleBar: UILabel
    // Button to display info about the app
    private let aboutButton: UIButton
    // Dividing bar
    private let divideView: UIView
    // View for different buttons
    public let sectionView: SectionView
    
    private let statusBarHeight = getStatusBarHeight()
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        contentView = UIView()
        titleBar = UILabel()
        aboutButton = UIButton()
        divideView = UIView()
        sectionView = SectionView()
        
        
        super.init(frame: frame)
        
        aboutButton.addTarget(self,
                              action: #selector(aboutButtonPress(sender:)),
                              for: .touchUpInside)
        
        addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(aboutButton)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        createAndActivateContentViewConstraints()
        createAndActivateTitleBarConstraints()
        createAndActiveAboutButtonConstraints()
        createAndActivateDivideViewConstraints()
        createAndActivateSectionViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        contentView = UIView()
        titleBar = UILabel()
        aboutButton = UIButton()
        divideView = UIView()
        sectionView = SectionView()
        
        super.init(coder: aDecoder)
        
        aboutButton.addTarget(self,
                              action: #selector(aboutButtonPress(sender:)),
                              for: .touchUpInside)
        
        addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(aboutButton)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        createAndActivateContentViewConstraints()
        createAndActivateTitleBarConstraints()
        createAndActiveAboutButtonConstraints()
        createAndActivateDivideViewConstraints()
        createAndActivateSectionViewConstraints()
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.zPosition = 100
        backgroundColor = .niceBlue
        
        // title bar
        titleBar.text = "Lifting Buddy"
        titleBar.font = titleBar.font.withSize(20.0)
        titleBar.textColor = .white
        titleBar.textAlignment = .center
        
        // About button
        aboutButton.setImage(#imageLiteral(resourceName: "Info"), for: .normal)
        
        
        // divide view
        divideView.layer.zPosition = 1
        divideView.backgroundColor = .white
        divideView.alpha = 0.2
    }
    
    // MARK: Event functions
    
    // Shows information about the app on dialog open
    @objc private func aboutButtonPress(sender: UIButton) {
        let alert = CDAlertView(title: "Lifting Buddy " +
            "v\(GBVersionTracking.currentVersion()!)",
            message: "Your free, open-source workout tracking application.\n\n" +
            "Email Support:\nchris@chrisperkins.me",
            type: CDAlertViewType.custom(image: #imageLiteral(resourceName: "LiftingBuddyImage")))
        alert.add(action: CDAlertViewAction(title: "Close",
                                            font: nil,
                                            textColor: UIColor.white,
                                            backgroundColor: UIColor.niceBlue,
                                            handler: nil))
        alert.add(action: CDAlertViewAction(title: "View website",
                                            font: nil,
                                            textColor: UIColor.white,
                                            backgroundColor: UIColor.niceBlue,
                                            handler: { (CDAlertViewAction) in
                                                // Open the app's URL
                                                UIApplication.shared.open(HeaderView.appURL,
                                                                          options: [:],
                                                                          completionHandler: nil)
        }))
        alert.show()
    }
    
    // MARK: Constraints
    
    // Cling to top, bottom, left, right
    private func createAndActivateContentViewConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: statusBarHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
    }
    
    // Cling to top of contentview, bottom to divideView ; centerx and width copy from contentview
    private func createAndActivateTitleBarConstraints() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: divideView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .width,
                                                             plusConstant: -100).isActive = true
    }
    
    // Place a little from the right of the contentview's right ; center vertically in container
    // height/width 32.
    private func createAndActiveAboutButtonConstraints() {
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: contentView,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: contentView,
                                                             attribute: .top,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: divideView,
                                                             attribute: .bottom,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint(item: aboutButton,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: aboutButton,
                           attribute: .width,
                           multiplier: 1,
                           constant: 0).isActive = true
        
    }
    
    // center vert in contentview ; cling to left, right to content view ; height 1
    private func createAndActivateDivideViewConstraints() {
        divideView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: divideView,
                                                             withCopyView: contentView,
                                                             attribute: .centerY,
                                                             plusConstant: 5).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: divideView,
                                                             withCopyView: contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: divideView,
                                                             withCopyView: contentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: divideView,
                                                         height: 1).isActive = true
    }
    
    // cling to top of divideview ; bottom,left,right of contentView
    private func createAndActivateSectionViewConstraints() {
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: sectionView,
                                                             withCopyView: divideView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: sectionView,
                                                             withCopyView: contentView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: sectionView,
                                                             withCopyView: contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: sectionView,
                                                             withCopyView: contentView,
                                                             attribute: .right).isActive = true
    }
}
