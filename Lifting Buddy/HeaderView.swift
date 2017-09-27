//
//  HeaderView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Header View shown at the top of the application at all times

import UIKit

class HeaderView: UIView {
    
    // MARK: View properties
    
    // Bar below status bar
    private var contentView: UIView
    // Bar that displays title of app
    private var titleBar: UILabel
    // Dividing bar
    private var divideView: UIView
    // View for different buttons
    private var sectionView: SectionView
    
    private let statusBarHeight = getStatusBarHeight()
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        contentView = UIView()
        titleBar = UILabel()
        divideView = UIView()
        sectionView = SectionView()
        
        
        super.init(frame: frame)
        
        self.addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        self.createAndActivateContentViewConstraints()
        self.createAndActivateTitleBarConstraints()
        self.createAndActivateDivideViewConstraints()
        self.createAndActivateSectionViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        contentView = UIView()
        titleBar = UILabel()
        divideView = UIView()
        sectionView = SectionView()
        
        super.init(coder: aDecoder)
        
        self.addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        self.createAndActivateContentViewConstraints()
        self.createAndActivateTitleBarConstraints()
        self.createAndActivateDivideViewConstraints()
        self.createAndActivateSectionViewConstraints()
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.zPosition = 100
        self.backgroundColor = UIColor.niceBlue()
        
        // title bar
        titleBar.text = "Lifting Buddy [DEVELOPMENT]"
        titleBar.font = titleBar.font.withSize(20.0)
        titleBar.textColor = .white
        titleBar.textAlignment = .center
        
        
        // divide view
        divideView.layer.zPosition = 1
        divideView.backgroundColor = .white
        divideView.alpha = 0.2
    }
    
    // MARK: Constraints
    
    // Cling to top, bottom, left, right
    func createAndActivateContentViewConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .top,
                           multiplier: 1,
                           constant: -statusBarHeight).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: contentView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to top,left,right to contentview, bottom to divideView
    func createAndActivateTitleBarConstraints() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: titleBar,
                                                            belowView: contentView,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: titleBar,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: titleBar,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: divideView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: titleBar,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // center vert in contentview ; cling to left, right to content view ; height 1
    func createAndActivateDivideViewConstraints() {
        divideView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: contentView,
                           attribute: .centerY,
                           relatedBy: .equal,
                           toItem: divideView,
                           attribute: .centerY,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: divideView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: divideView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: divideView,
                                                         height: 1).isActive = true
    }
    
    // cling to top of divideview ; bottom,left,right of contentView
    func createAndActivateSectionViewConstraints() {
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: sectionView,
                                                            belowView: divideView,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: sectionView,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: sectionView,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: contentView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: sectionView,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
