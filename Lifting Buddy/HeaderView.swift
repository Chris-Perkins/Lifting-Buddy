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
        self.backgroundColor = UIColor.niceBlue
        
        // title bar
        titleBar.text = "Lifting Buddy [ALPHA]"
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
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .bottom).isActive = true
    }
    
    // center vert in contentview ; cling to left, right to content view ; height 1
    func createAndActivateDivideViewConstraints() {
        divideView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.divideView,
                                                             withCopyView: self.contentView,
                                                             attribute: .centerY,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.divideView,
                                                             withCopyView: self.contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.divideView,
                                                             withCopyView: self.contentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: divideView,
                                                         height: 1).isActive = true
    }
    
    // cling to top of divideview ; bottom,left,right of contentView
    func createAndActivateSectionViewConstraints() {
        self.sectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.sectionView,
                                                             withCopyView: self.divideView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.sectionView,
                                                             withCopyView: self.contentView,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.sectionView,
                                                             withCopyView: self.contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.sectionView,
                                                             withCopyView: self.contentView,
                                                             attribute: .right).isActive = true
    }
}
