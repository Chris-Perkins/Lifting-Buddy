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
    private let contentView: UIView
    // Bar that displays title of app
    private let titleBar: UILabel
    // Dividing bar
    private let divideView: UIView
    // View for different buttons
    public let sectionView: SectionView
    
    private let statusBarHeight = getStatusBarHeight()
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        contentView = UIView()
        titleBar = UILabel()
        divideView = UIView()
        sectionView = SectionView()
        
        
        super.init(frame: frame)
        
        addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        createAndActivateContentViewConstraints()
        createAndActivateTitleBarConstraints()
        createAndActivateDivideViewConstraints()
        createAndActivateSectionViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        contentView = UIView()
        titleBar = UILabel()
        divideView = UIView()
        sectionView = SectionView()
        
        super.init(coder: aDecoder)
        
        addSubview(contentView)
        contentView.addSubview(titleBar)
        contentView.addSubview(divideView)
        contentView.addSubview(sectionView)
        
        createAndActivateContentViewConstraints()
        createAndActivateTitleBarConstraints()
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
        
        
        // divide view
        divideView.layer.zPosition = 1
        divideView.backgroundColor = .white
        divideView.alpha = 0.2
    }
    
    // MARK: Constraints
    
    // Cling to top, bottom, left, right
    func createAndActivateContentViewConstraints() {
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
    
    // Cling to top,left,right to contentview, bottom to divideView
    func createAndActivateTitleBarConstraints() {
        titleBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: contentView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleBar,
                                                             withCopyView: divideView,
                                                             attribute: .bottom).isActive = true
    }
    
    // center vert in contentview ; cling to left, right to content view ; height 1
    func createAndActivateDivideViewConstraints() {
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
    func createAndActivateSectionViewConstraints() {
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
