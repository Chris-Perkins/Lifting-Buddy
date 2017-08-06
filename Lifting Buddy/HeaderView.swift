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
    
    private var sectionContentView: UIView?
    
    // MARK: Overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.niceBlue()
        
        // Need status bar height to not overlap other views
        let statusBarHeight = getStatusBarHeight()
        
        // Divide between title bar and navigation bar (subtract out statusBarHeight for no overlap)
        let divide: CGFloat = (self.frame.height - statusBarHeight) / 2.0
        
        // Bar that displays title of app
        let titleBar: UILabel = UILabel(frame: CGRect(x: 0,
                                                      y: statusBarHeight + 10,
                                                      width: self.frame.width,
                                                      height: divide - 10))
        titleBar.text = "Lifting Buddy [ALPHA]"
        titleBar.font = titleBar.font.withSize(20.0)
        titleBar.textColor = .white
        titleBar.textAlignment = .center
        self.addSubview(titleBar)
        
        // Dividing bar
        let divideView: UIView = UIView(frame: CGRect(x: 0,
                                                      y: 10.0 + statusBarHeight + divide,
                                                      width: self.frame.width,
                                                      height: 1))
        divideView.backgroundColor = .white
        divideView.alpha = 0.2
        self.addSubview(divideView)
        
        // View for different buttons
        let sectionsView: SectionView = SectionView(frame: CGRect(x: 0,
                                                                  y: statusBarHeight + divide + 10,
                                                                  width: self.frame.width,
                                                                  height: divide - 10))
        self.addSubview(sectionsView)
        
        super.layoutSubviews()
    }
    
    // MARK: Custom view functions
    
    // Set the section view we change to
    public func setSectionContentView(sectionContentView: UIView) {
        self.sectionContentView = sectionContentView
    }
}
