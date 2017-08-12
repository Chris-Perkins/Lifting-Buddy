//
//  ViewHelperFunctions.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//


/// Functions to help make the application more readable.

import UIKit
import RealmSwift
import Realm

// Returns the height of the status bar (battery view, etc)
func getStatusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}


// MARK: Extensions

extension UIView {
    // Add an array of views to a main view with equal vertical spacing
    func addSubviewsToViewWithYPadding(subviews: [UIView], spacing: CGFloat = -1) {
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
            trueSpacing = (self.frame.height - totalVerticalHeight) / CGFloat(subviews.count - 1)
        } else {
            // Divide by two because... there's a header and footer. 1 + 1 = 2
            headerFooterSpacing = (self.frame.height - totalVerticalHeight -
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
            
            self.addSubview(view)
        }
    }
    
    // Removes all subviews from a given view
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
}

extension UIColor {
    public static func niceBlue() -> UIColor {
        return UIColor(red: 0.291269, green: 0.459894, blue: 0.909866, alpha: 1)
    }
    
    public static func niceLightBlue() -> UIColor {
        return UIColor(red: 0.8, green: 0.78, blue: 0.96, alpha: 1)
    }
    
    public static func niceYellow() -> UIColor {
        return UIColor(red: 0.90, green: 0.70, blue: 0.16, alpha: 1)
    }
    
    public static func niceGreen() -> UIColor {
        return UIColor(red: 0.27, green: 0.66, blue: 0.3, alpha: 1)
    }
}

extension NSDate {
    // Get the current day of the week (in string format) ex: "Monday"
    public func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
}

extension Results {
    // Returns array of results from Realm
    public func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    // Returns array of results from Realm List
    public func toArray() -> [T] {
        return self.map{$0}
    }
}
