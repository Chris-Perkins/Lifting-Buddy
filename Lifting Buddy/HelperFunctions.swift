//
//  HelperFunctions.swift
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
import CDAlertView

// Time amount values (used in graphing)
public enum TimeAmount: String {
    case month   = "MONTH"
    case year    = "YEAR"
    case alltime = "ALL-TIME"
}

// Used in getting user defined color scheme from userdefaults
public let colorSchemeKey = "colorScheme"
public enum ColorScheme: Int {
    case light = 0
    case dark  = 1
}

public var activeColorScheme: ColorScheme {
    guard let storedValue = UserDefaults.standard.value(forKey: colorSchemeKey) as? Int,
          let colorScheme = ColorScheme(rawValue: storedValue) else {
        fatalError("Could not retrieve the active color scheme")
    }
    return colorScheme
}
public func setNewColorScheme(_ scheme: ColorScheme) {
    let userDefaults = UserDefaults.standard
    userDefaults.set(scheme.rawValue, forKey: colorSchemeKey)
}

// An associated array for easy parsing
public let TimeAmountArray = [TimeAmount.month, TimeAmount.year, TimeAmount.alltime]
public let daysOfTheWeekChars = ["S", "M", "T", "W", "T", "F", "S"]

// Returns the height of the status bar (battery view, etc)
var statusBarHeight: CGFloat {
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


// MARK: Global functions

// Gets the colors associated with an index
func getColorsForIndex(_ passedIndex: Int) -> [UIColor] {
    var colors = [UIColor]()
    let modCount = 10
    
    // Lets us modify the index that was passed in
    var index = passedIndex
    // + 1 so index starting at 0 is given a color
    index += 1
    var i = 0
    var previousColor = -1
    while index > 0 {
        var color: UIColor?
        var colorIndex = mod(x: index, m: modCount)
        if colorIndex == previousColor {
            colorIndex = mod(x: colorIndex + 1, m: modCount)
        }
        
        switch (colorIndex) {
        case 0:
            color = .niceRed
        case 1:
            color = .niceBlue
        case 2:
            color = .niceGreen
        case 3:
            color = .niceYellow
        case 4:
            color = .niceCyan
        case 5:
            color = .niceBrown
        case 6:
            color = .nicePurple
        case 7:
            color = .niceMediterranean
        case 8:
            color = .niceMaroon
        case 9:
            color = .niceOrange
        default:
            fatalError("Modulo returned OOB value. Check case amount in ExerciseChartCreator -> GetLineColor Method")
        }
        
        i += 1
        // Up this based on mod count. Should be the ceil of closest 10 to modCount
        // Ex: modCount 9 -> 10, modCount 11 -> 100
        index = index / 10^^i
        previousColor = colorIndex
        colors.append(color!)
    }
    return colors
}

// Just mods a number so it doesn't return -1
func mod(x: Int, m: Int) -> Int {
    let r = x % m
    return r < 0 ? r + m : r
}

func mod(x: Float, m: Float) -> Float {
    let r = x.truncatingRemainder(dividingBy: m)
    return r < 0 ? r + m : r
}

// MARK: Extensions

extension BetterTextField {
    public static var defaultHeight: CGFloat {
        return 50
    }
}

extension Chart {
    public static var defaultHeight: CGFloat {
        return 300
    }
}

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
    public func getDayOfWeek(_ fromDate: String, formatter: DateFormatter = NSDate.getDateFormatter()) -> Int? {
        guard let date = formatter.date(from: fromDate) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay
    }
}

extension Date {
    private static let daysOfTheWeek =
        ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    public static func getDaysOfTheWeekStrings() -> [String] {
        return daysOfTheWeek;
    }
    
    /**
     Attempts to convert an index into the correspondent weekday string; 0-indexed.
     
     - Parameter index: the index of the date (0 is Sunday, 6 is Saturday)
     - Returns: A String representing the name of the weekday if the index is valid; nil otherwise.
    */
    public static func convertDayIndexToWeekdayName(dayIndex index: Int) -> String? {
        if (index < 0 || index >= daysOfTheWeek.count) {
            return nil
        }
        
        return daysOfTheWeek[index]
    }
    
    /**
     Attempts to convert a String into the index of the day of the week it's related to; 0-indexed.
     
     - Parameter weekdayName: The String that represents a weekday name
     - Returns: The index of the weekday (0-indexed) if it could be found; nil otherwise.
    */
    public static func convertWeekdayNameToIndex(weekdayName: String) -> Int? {
        if (daysOfTheWeek.contains(weekdayName)) {
            return daysOfTheWeek.index(of: weekdayName)
        } else {
            return nil
        }
    }
    
    /**
     Attempts to get the day of the week for the Date instance; 0-indexed.
     
     - Returns: The index of the day of the week this date is; 0-indexed.
    */
    public func getDayOfTheWeekIndex() -> Int {
        let date = Date()
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: date)
        return weekDay - 1
    }
}

extension Int {
    public func modulo(_ moduloNumber: Int) -> Int {
        let moduloValue = self % moduloNumber
        
        return moduloValue < 0 ? moduloValue + moduloNumber : moduloValue
    }
}

extension NSLayoutConstraint {
    
    // Clings a view to the entirety of toView
    public static func clingViewToView(view: UIView,
                                       toView: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: toView,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: toView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: toView,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                             withCopyView: toView,
                                                             attribute: .bottom).isActive = true
    }
    
    // Return a constraint that will place a view below's top a view with padding
    public static func createViewBelowViewConstraint(view: UIView,
                                                     belowView: UIView,
                                                     withPadding: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: belowView,
                                  attribute: .bottom,
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
    
    // Just a faster way to create a layout constraint copy. The original way is waaaay too long.
    public static func createViewAttributeCopyConstraint(view: UIView,
                                                         withCopyView: UIView,
                                                         attribute: NSLayoutConstraint.Attribute,
                                                         multiplier: CGFloat = 1.0,
                                                         plusConstant: CGFloat = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: withCopyView,
                                  attribute: attribute,
                                  relatedBy: .equal,
                                  toItem: view,
                                  attribute: attribute,
                                  multiplier: (1/multiplier),
                                  constant: -plusConstant)
    }
}

extension PrettyButton {
    public static var defaultHeight: CGFloat {
        return 50
    }
    
    override func setDefaultProperties() {
        backgroundColor = .niceBlue
        setOverlayColor(color: .niceYellow)
        setOverlayStyle(style: .fade)
        cornerRadius = 0
    }
}

extension PrettySegmentedControl {
    public static var defaultHeight: CGFloat {
        return 30
    }
}

extension String {
    var floatValue: Float? {
        return Float(self)
    }
}

extension UIColor {
    
    public static var primaryBlackWhiteColor: UIColor {
        switch(activeColorScheme) {
        case .light:
            return .white
        case .dark:
            return .niceBlack
        }
    }
    
    public static var lightBlackWhiteColor: UIColor {
        switch(activeColorScheme) {
        case .light:
            return .niceLightGray
        case .dark:
            return .niceDarkestGray
        }
    }
    
    public static var lightestBlackWhiteColor: UIColor {
        switch(activeColorScheme) {
        case .light:
            return .niceLightestGray
        case .dark:
            return .niceDarkGray
        }
    }
    
    public static var oppositeBlackWhiteColor: UIColor {
        switch(activeColorScheme) {
        case .light:
            return .niceBlack
        case .dark:
            return .white
        }
    }
    
    public static var niceBlack: UIColor {
        return UIColor(hue: 0, saturation: 0, brightness: 0.075, alpha: 1.0)
    }
    
    public static var niceBlue: UIColor {
        switch(activeColorScheme) {
        case .light:
            return UIColor(red: 0.291269, green: 0.459894, blue: 0.909866, alpha: 1)
        case .dark:
            return UIColor(red: 0.4196, green: 0.6196, blue: 0.909866, alpha: 1.0)
        }
    }
    
    public static var niceBrown: UIColor {
        return UIColor(red: 0.6471, green: 0.3647, blue: 0.149, alpha: 1.0)
    }
    
    public static var niceCyan: UIColor {
        return UIColor(red: 0.149, green: 0.651, blue: 0.6588, alpha: 1.0)
    }
    
    public static var niceDarkGray: UIColor {
        return UIColor(hue: 0, saturation: 0, brightness: 0.225, alpha: 1.0)
    }
    
    public static var niceDarkestGray: UIColor {
        return UIColor(hue: 0, saturation: 0, brightness: 0.15, alpha: 1.0)
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
        return UIColor(hue: 0, saturation: 0, brightness: 0.895, alpha: 1.0)
    }
    
    public static var niceLightestGray: UIColor {
        return UIColor(hue: 0, saturation: 0, brightness: 0.95, alpha: 1.0)
    }
    
    public static var niceLightGreen: UIColor {
        switch(activeColorScheme) {
        case .light:
            return UIColor(red: 0.85, green: 0.95, blue: 0.85, alpha: 1)
        case .dark:
            return UIColor(red: 0.1176, green: 0.2667, blue: 0.1176, alpha: 1.0)
        }
    }
    
    public static var niceLightRed: UIColor {
        return UIColor(red: 0.9686, green: 0.5176, blue: 0.3647, alpha: 1.0)
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
        return UIImage(cgImage: cgImage!, scale: 1, orientation: UIImage.Orientation.right)
    }
    
    public func rotateNinetyDegreesCounterClockwise() -> UIImage {
        return UIImage(cgImage: cgImage!, scale: 1, orientation: UIImage.Orientation.left)
    }
}

extension UILabel {
    public static var titleLabelTextColor: UIColor {
        return .niceBlue
    }
    public static var titleLabelBackgroundColor: UIColor {
        return .lightestBlackWhiteColor
    }
    public static var titleLabelHeight: CGFloat {
        return 50.0
    }
    
    override func setDefaultProperties() {
        font = UIFont.boldSystemFont(ofSize: 18.0)
        textAlignment = .center
        textColor = .niceBlue
    }
}

extension UITableView {
    
    // Returns all cells in a uitableview
    public func getAllCells() -> [UITableViewCell] {
        var cells = [UITableViewCell]()
        
        for i in 0...numberOfSections - 1 {
            for j in 0...numberOfRows(inSection: i) {
                if let cell = cellForRow(at: IndexPath(row: j, section: i)) {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }
}

extension UITableViewCell {
    public static var defaultHeight: CGFloat {
        return 50
    }
}

extension UITextField {
    
    var isNumeric: Bool {
        if let text = text {
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
        addTarget(self, action: #selector(textfieldSelected(sender:)), for: .editingDidBegin)
        addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        
        // View prettiness
        textAlignment = .center
    }
    
    // MARK: Textfield events
    
    @objc func textfieldSelected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = .niceYellow
            sender.textColor = .white
        })
    }
    
    @objc func textfieldDeselected(sender: UITextField) {
        UIView.animate(withDuration: 0.1, animations: {
            sender.backgroundColor = .primaryBlackWhiteColor
            sender.textColor = .oppositeBlackWhiteColor
        })
    }
    
    @objc public func setPlaceholderString(_ placeholder: String?) {
        if let placeholder = placeholder {
            let attributedText = NSAttributedString(string: placeholder,
                                                    attributes: [NSAttributedString.Key.foregroundColor:
                                                        UIColor.oppositeBlackWhiteColor.withAlphaComponent(
                                                            0.25)])
            attributedPlaceholder = attributedText
        } else {
            attributedPlaceholder = nil
        }
    }
    
    @objc public func getPlaceholderString() -> String? {
        return attributedPlaceholder?.string
    }
    
    public func resetColors() {
        setPlaceholderString(getPlaceholderString())
        textfieldDeselected(sender: self)
    }
}

extension UIView {
    // Shows a view over this view using constraints
    static func slideView(_ coveringView: UIView, overView inView: UIView) {
        // Don't want user interacting with the view if it shouldn't be interactable at this time.
        inView.isUserInteractionEnabled = false
        
        inView.addSubview(coveringView)
        
        // Constraints take up the whole view. Start above the view (not visible)
        coveringView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: coveringView,
                                                             withCopyView: inView,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: coveringView,
                                                             withCopyView: inView,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: coveringView,
                                                             withCopyView: inView,
                                                             attribute: .height).isActive = true
        /*
         We can use the inView's height as the basis for "above this view" since
         coveringView's height is equal to the height of the inView
        */
        let heightConstraint = NSLayoutConstraint.createViewAttributeCopyConstraint(
            view: coveringView,
            withCopyView: inView,
            attribute: .top,
            plusConstant: -inView.frame.height)
        heightConstraint.isActive = true
        // Activate these constraints
        inView.layoutIfNeeded()
        
        // Moves the view to the bottom upon calling layout if needed
        heightConstraint.constant = 0
        
        // Animate the transition between top to bottom to slide down
        UIView.animate(withDuration: 0.2, animations: {
            inView.layoutIfNeeded()
        }, completion: {Bool in
            inView.isUserInteractionEnabled = true
        })
    }
    
    // Calls layoutSubviews on ALL subviews recursively
    func layoutAllSubviews() {
        for subview in subviews {
            (subview as? UITextField)?.resetColors()
            subview.layoutAllSubviews()
        }
        
        layoutSubviews()
    }
    
    @objc func setDefaultProperties() {
        // Override me!
    }
    
    // Removes all subviews from a given view
    func removeAllSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }
    
    // Removes itself from this superview by sliding up and fading out
    func removeSelfNicelyWithAnimation() {
        // Prevent user interaction with all subviews
        for subview in subviews {
            subview.isUserInteractionEnabled = false
        }
        
        // Slide up, then remove from view
        UIView.animate(withDuration: 0.2, animations: {
            self.frame = CGRect(x: 0,
                                y: -self.frame.height,
                                width: self.frame.width,
                                height: self.frame.height)
        }, completion: { (finished:Bool) -> Void in
            self.removeFromSuperview()
        })
    }
}
