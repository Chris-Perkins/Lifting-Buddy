//
//  ViewHelperFunctions.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

// Add an array of views to a main view with equal vertical spacing
func addSubviewsToViewWithYPadding(mainView: UIView, subviews: [UIView], spacing: CGFloat = -1) {
    var trueSpacing: CGFloat = spacing
    var headerFooterSpacing: CGFloat = 0
    
    // Get current height of all subviews
    var totalVerticalHeight:CGFloat = 0
    for view in subviews {
        totalVerticalHeight += view.frame.height
    }
    
    // If unassigned (or invalid), space equally through whole view
    if spacing < 0 {
        // Divide by subviews.count - 1 as we don't wait trailing spacing.
        // Example: 2 views needs 1 thing of padding (not two)
        trueSpacing = (mainView.frame.height - totalVerticalHeight) / CGFloat(subviews.count - 1)
    } else {
        // Divide by two because... there's a header and footer. 1 + 1 = 2
        headerFooterSpacing = (mainView.frame.height - totalVerticalHeight -
                               spacing * (CGFloat(subviews.count) - 1)) / 2
    }
    
    // Add in each frame with appropriate spacing
    // Keep track of current forced height to prevent overlap
    var currentHeight: CGFloat = headerFooterSpacing
    for (index, view) in subviews.enumerated() {
        view.frame = CGRect(x: view.frame.minX,
                            y: currentHeight + trueSpacing * CGFloat(index),
                            width: view.frame.width, height: view.frame.height)
        currentHeight += view.frame.height
        
        mainView.addSubview(view)
    }
}
