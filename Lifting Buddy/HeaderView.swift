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
        self.titleBar.text = "Lifting Buddy [ALPHA]"
        self.titleBar.font = titleBar.font.withSize(20.0)
        self.titleBar.textColor = .white
        self.titleBar.textAlignment = .center
        
        
        // divide view
        self.divideView.layer.zPosition = 1
        self.divideView.backgroundColor = .white
        self.divideView.alpha = 0.2
    }
    
    // MARK: Constraints
    
    // Cling to top, bottom, left, right
    func createAndActivateContentViewConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.contentView,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: self.statusBarHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.contentView,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.contentView,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.contentView,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
    }
    
    // Cling to top,left,right to contentview, bottom to divideView
    func createAndActivateTitleBarConstraints() {
        self.titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.contentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleBar,
                                                             withCopyView: self.divideView,
                                                             attribute: .bottom).isActive = true
    }
    
    // center vert in contentview ; cling to left, right to content view ; height 1
    func createAndActivateDivideViewConstraints() {
        divideView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.divideView,
                                                             withCopyView: self.contentView,
                                                             attribute: .centerY,
                                                             plusConstant: 10).isActive = true
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
