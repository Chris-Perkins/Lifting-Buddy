//
//  SettingsContentView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 1/9/18.
//  Copyright © 2018 Christopher Perkins. All rights reserved.
//

import UIKit

class SettingsContentView: UIScrollView {
    
    // MARK: View properties
    
    // The padding between every view
    private static let paddingBetweenRelatedViews: CGFloat = 12.5
    private static let paddingBetweenSettings = 2 * paddingBetweenRelatedViews
    
    // Simply says the color scheme
    let colorSchemeLabel: UILabel
    // The view where we actively determine
    let colorSchemePicker: PrettySegmentedControl
    
    override init(frame: CGRect) {
        colorSchemeLabel = UILabel()
        colorSchemePicker = PrettySegmentedControl(labelStrings: ["Light", "Dark"],
                                                   frame: .zero,
                                                   defaultIndex: activeColorScheme.rawValue)
        
        super.init(frame: frame)
        
        addSubview(colorSchemeLabel)
        addSubview(colorSchemePicker)
        
        colorSchemePicker.delegate = self
        
        createAndActivateColorSchemeLabelConstraints()
        createAndActivateColorSchemePickerConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self
        backgroundColor = .lightBlackWhiteColor
        
        // Color Scheme Label
        colorSchemeLabel.setDefaultProperties()
        colorSchemeLabel.backgroundColor = UILabel.titleLabelBackgroundColor
        colorSchemeLabel.textColor       = UILabel.titleLabelTextColor
        colorSchemeLabel.text            = "Active Color Scheme"
    }
    
    // DEBUG FUNCTION
    // Modify later.
    private func setNewColorScheme(_ scheme: ColorScheme) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(scheme.rawValue, forKey: colorSchemeString)
    }
    
    // Cling to top, left, right of self; height of titleLabelDefault
    private func createAndActivateColorSchemeLabelConstraints() {
        colorSchemeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: colorSchemeLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: colorSchemeLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: colorSchemeLabel,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: colorSchemeLabel,
                                                         height: UILabel.titleLabelHeight).isActive = true
    }
    
    // Place below colorSchemeLabel ; center horiz in view ; width of this view * 0.8 ; height default
    private func createAndActivateColorSchemePickerConstraints() {
        colorSchemePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: colorSchemePicker,
                                                         belowView: colorSchemeLabel,
                                                         withPadding: SettingsContentView.paddingBetweenRelatedViews
                                                        ).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: colorSchemePicker,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: colorSchemePicker,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.8).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: colorSchemePicker,
                                                         height: PrettySegmentedControl.defaultHeight
                                                        ).isActive = true
    }
}

extension SettingsContentView: PrettySegmentedControlDelegate {
    func segmentSelectionChanged(index: Int) {
        setNewColorScheme(ColorScheme(rawValue: index)!)
        
        viewController()?.viewWillLayoutSubviews()
        viewController()?.view?.layoutAllSubviews()
    }
    
}
