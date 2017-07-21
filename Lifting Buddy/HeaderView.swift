//
//  HeaderView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class HeaderView: UIView {
    override func layoutSubviews() {
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
        let sectionsView: SectionView = SectionView(frame: CGRect(x: 5,
                                                                  y: statusBarHeight + divide + 10,
                                                                  width: self.frame.width - 10,
                                                                  height: divide - 10))
        self.addSubview(sectionsView)
        
        super.layoutSubviews()
    }
    
}
