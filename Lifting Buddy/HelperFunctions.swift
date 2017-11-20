//
//  ViewHelperFunctions.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/16/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//


/// Functions to help make the application more readable.
/// Application defaults are stored here.

import UIKit
import RealmSwift
import Realm
import SwiftCharts

// Returns the height of the status bar (battery view, etc)
func getStatusBarHeight() -> CGFloat {
    let statusBarSize = UIApplication.shared.statusBarFrame.size
    return Swift.min(statusBarSize.width, statusBarSize.height)
}


// MARK: Operators

// let's us do pow function easier.
precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

// MARK: Extensions

extension ChartSettings {
    // Default chart settings for this project
    public static func getDefaultSettings() -> ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 15
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 4
        chartSettings.axisStrokeWidth = 0.2
        chartSettings.spacingBetweenAxesX = 8
        chartSettings.spacingBetweenAxesY = 8
        chartSettings.labelsSpacing = 0
        chartSettings.zoomPan.zoomEnabled = true
        chartSettings.zoomPan.panEnabled = true
        
        return chartSettings
    }
}

extension NSDate {
    // Returns the default date formatter for this project
    public static func getDateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter
    }
    
    // Get the current day of the week (in string format) ex: "Monday"
    public func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
    
    // Gets the day of the week as a string
    public func getDayOfWeek(_ fromDate:String, formatter: DateFormatter = NSDate.getDateFormatter()) -> Int? {
        guard let date = formatter.date(from: fromDate) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay
    }
}

extension NSLayoutConstraint {
    
    // Clings a view to the entirety of toView
    public static func clingViewToView(view: UIView,
                                   toView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: view,
                                                            belowView: toView,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: toView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Return a constraint that will center a view inside a view
    public static func createCenterViewHorizontallyInViewConstraint(view: UIView,
                                                                    inView: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: inView,
                                  attribute: .centerX,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .centerX,
                                  multiplier: 1,
                                  constant: 0)
    }
    
    // Return a constraint that will place a view below a view with padding
    public static func createViewBelowViewConstraint(view: UIView,
                                                     belowView: UIView,
                                                     withPadding: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: belowView,
                                  attribute: .bottom,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: -withPadding)
    }
    
    // Return a constraint that will place a view below's top a view with padding
    public static func createViewBelowViewTopConstraint(view: UIView,
                                                        belowView: UIView,
                                                        withPadding: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: belowView,
                                  attribute: .top,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .top,
                                  multiplier: 1,
                                  constant: -withPadding)
    }
    
    // Return a constraint that will create a width constraint for the given view
    public static func createWidthConstraintForView(view: UIView,
                                                    width: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: width)
    }
    
    // Return a constraint that will create a height constraint for the given view
    public static func createHeightConstraintForView(view: UIView,
                                                     height: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view,
                                  attribute: .height,
                                  relatedBy: .equal,
                                  toItem: nil,
                                  attribute: .notAnAttribute,
                                  multiplier: 1,
                                  constant: height)
    }
    
    public static func createWidthCopyConstraintForView(view: UIView,
                                                        withCopyView: UIView,
                                                        plusWidth: CGFloat) -> NSLayoutConstraint{
        return NSLayoutConstraint(item: withCopyView,
                                  attribute: .width,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: .width,
                                  multiplier: 1,
                                  constant: -plusWidth)
    }
}

extension PrettyButton {
    override func setDefaultProperties() {
        self.backgroundColor = UIColor.niceBlue
        self.setOverlayColor(color: UIColor.niceYellow)
        self.setOverlayStyle(style: .FADE)
        self.cornerRadius = 0
    }
}

extension String {
    var floatValue: Float? {
        return NumberFormatter().number(from: self)?.floatValue
    }
}

extension UIColor {
    public static var niceBlue: UIColor {
        return UIColor(red: 0.291269, green: 0.459894, blue: 0.909866, alpha: 1)
    }
    
    public static var niceBrown: UIColor {
        return UIColor(red: 0.6471, green: 0.3647, blue: 0.149, alpha: 1.0)
    }
    
    public static var niceCyan: UIColor {
        return UIColor(red: 0.149, green: 0.651, blue: 0.6588, alpha: 1.0)
    }
    
    public static var niceGray: UIColor {
        return UIColor(red: 0.90, green: 0.90, blue: 0.90, alpha: 1)
    }
    
    public static var niceGreen: UIColor {
        return UIColor(red: 0.27, green: 0.66, blue: 0.3, alpha: 1)
    }
    
    public static var niceLabelBlue: UIColor {
        return UIColor(red: 0.44, green: 0.56, blue: 0.86, alpha: 1)
    }
    
    public static var niceLightBlue: UIColor {
        return UIColor(red: 0.8, green: 0.78, blue: 0.96, alpha: 1)
    }
    
    public static var niceLightGray: UIColor {
        return UIColor(red: 0.965, green: 0.965, blue: 0.965, alpha: 1.0)
    }
    
    public static var niceLightGreen: UIColor {
        return UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1)
    }
    
    public static var niceMaroon: UIColor {
        return UIColor(red: 0.349, green: 0.0784, blue: 0.0784, alpha: 1.0)
    }
    
    public static var niceMediterranean: UIColor {
        return UIColor(red: 0.0745, green: 0.2235, blue: 0.3373, alpha: 1.0)
    }
    
    public static var niceOrange: UIColor {
        return UIColor(red: 1, green: 0.4118, blue: 0.1569, alpha: 1.0)
    }
    
    public static var nicePurple: UIColor {
        return UIColor(red: 0.5882, green: 0.1451, blue: 0.6392, alpha: 1.0)
    }
    
    public static var niceRed: UIColor {
        return UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1)
    }
    
    public static var niceYellow: UIColor {
        return UIColor(red: 0.90, green: 0.70, blue: 0.16, alpha: 1)
    }
}

extension UIImage {
    public func rotateNinetyDegreesClockwise() -> UIImage {
        return UIImage(cgImage: self.cgImage!, scale: 1, orientation: UIImageOrientation.right)
    }
    
    public func rotateNinetyDegreesCounterClockwise() -> UIImage {
        return UIImage(cgImage: self.cgImage!, scale: 1, orientation: UIImageOrientation.left)
    }
}

extension UILabel {
    override func setDefaultProperties() {
        self.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.textAlignment = .center
        self.textColor = UIColor.niceBlue
    }
}

extension UITableView {
    
    // Returns all cells in a uitableview
    public func getAllCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        
        for i in 0...self.numberOfSections - 1 {
            for j in 0...self.numberOfRows(inSection: i) {
                if let cell = self.cellForRow(at: IndexPath(row: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }
}

extension UITextField {
    var isNumeric: Bool {
        if let text = self.text {
            if text.count == 0 { return true }
        
            let setNums: Set<Character> = Set(arrayLiteral: "1", "2", "3", "4",
                                                        "5", "6", "7", "8",
                                                        "9", "0")
        
            return Set(text).isSubset(of: setNums)
        } else {
            return false
        }
    }
    
    override func setDefaultProperties() {
        // View select / deselect events
        self.addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
        self.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        
        // View prettiness
        self.textAlignment = .center
        
        self.textfieldDeselected(sender: self)
    }
    
    // MARK: Textfield events
    
    @objc func textfieldSelected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = UIColor.niceYellow
            sender.textColor = UIColor.white
        })
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = UIColor.white
            sender.textColor = UIColor.black
        })
    }
}

extension UIView {
    @objc func setDefaultProperties() {
        // Override me!
    }
    
    // Removes all subviews from a given view
    func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    // Removes itself from this superview by sliding up and fading out
    func removeSelfNicelyWithAnimation() {
        // Prevent user interaction with all subviews
        for subview in self.subviews {
            subview.isUserInteractionEnabled = false
        }
        
        // Slide up, then remove from view
        UIView.animate(withDuration: 0.2,
                       animations: {
                            self.frame = CGRect(x: 0,
                                                y: -self.frame.height,
                                                width: self.frame.width,
                                                height: self.frame.height)
                        },
                       completion: { (finished:Bool) -> Void in
                            self.removeFromSuperview()
                        })
    }
}
