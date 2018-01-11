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
    private let colorSchemeLabel: UILabel
    // The view where we actively determine
    private let colorSchemePicker: PrettySegmentedControl
    // Label that asks user about features/bugs
    private let featureRequestLabel: UILabel
    // Button to send an email
    private let emailButton: PrettyButton
    // Contribution label
    private let contributeLabel: UILabel
    // Contribution button
    private let contributeButton: PrettyButton
    // Website Label
    private let websiteLabel: UILabel
    // Website button
    private let websiteButton: PrettyButton
    
    override init(frame: CGRect) {
        // Initializing
        
        colorSchemeLabel  = UILabel()
        colorSchemePicker = PrettySegmentedControl(labelStrings: ["Light", "Dark"],
                                                   frame: .zero,
                                                   defaultIndex: activeColorScheme.rawValue)
        featureRequestLabel = UILabel()
        emailButton         = PrettyButton()
        contributeLabel     = UILabel()
        contributeButton    = PrettyButton()
        websiteLabel        = UILabel()
        websiteButton       = PrettyButton()
        
        super.init(frame: frame)
        
        // Adding subviews, setting delegates/events
        
        addSubview(colorSchemeLabel)
        addSubview(colorSchemePicker)
        addSubview(featureRequestLabel)
        addSubview(emailButton)
        addSubview(contributeLabel)
        addSubview(contributeButton)
        addSubview(websiteLabel)
        addSubview(websiteButton)
        
        colorSchemePicker.delegate = self
        
        emailButton.addTarget(     self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        contributeButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        websiteButton.addTarget(   self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        // Constraints below
        
        createAndActivateLabelConstraints(label: colorSchemeLabel, belowView: self)
        createAndActivateContentViewConstraints(contentView: colorSchemePicker, belowView: colorSchemeLabel)
        
        createAndActivateLabelConstraints(label: featureRequestLabel, belowView: colorSchemePicker)
        createAndActivateContentViewConstraints(contentView: emailButton, belowView: featureRequestLabel)
        
        createAndActivateLabelConstraints(label: contributeLabel, belowView: emailButton)
        createAndActivateContentViewConstraints(contentView: contributeButton, belowView: contributeLabel)
        
        createAndActivateLabelConstraints(label: websiteLabel, belowView: contributeButton)
        createAndActivateContentViewConstraints(contentView: websiteButton, belowView: websiteLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self
        backgroundColor = .lightBlackWhiteColor
        contentSize = CGSize(width: 0, height: websiteButton.frame.maxY +
                                                SettingsContentView.paddingBetweenSettings)
        
        // Color Scheme Label
        giveLabelProperties(label: colorSchemeLabel)
        colorSchemeLabel.text = "Active Color Scheme"
        
        // Feature request label
        giveLabelProperties(label: featureRequestLabel)
        featureRequestLabel.text = "Features? Bugs? Contact me!"
        
        // Email Me Button
        emailButton.setDefaultProperties()
        emailButton.setTitle("chris@chrisperkins.me", for: .normal)
        
        // Contribute label
        giveLabelProperties(label: contributeLabel)
        contributeLabel.text = "Do you know how to code?"
        
        // Contribute button
        contributeButton.setDefaultProperties()
        contributeButton.setTitle("View on GitHub", for: .normal)
        
        // Website label
        giveLabelProperties(label: websiteLabel)
        websiteLabel.text = "Visit Lifting Buddy's site!"
        
        // Website button
        websiteButton.setDefaultProperties()
        websiteButton.setTitle("Learn More", for: .normal)
    }
    
    // MARK: Custom view functions
    
    private func giveLabelProperties(label: UILabel) {
        label.setDefaultProperties()
        label.backgroundColor = UILabel.titleLabelBackgroundColor
        label.textColor       = UILabel.titleLabelTextColor
    }
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: PrettyButton) {
        switch(sender) {
        case emailButton:
            if let url = URL(string: "mailto:chris@chrisperkins.me") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case contributeButton:
            if let url = URL(string: "https:////github.com//Chris-Perkins//Lifting-Buddy") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case websiteButton:
            if let url = URL(string: "http:////chrisperkins.me//LiftingBuddy//") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            fatalError("Button press sent, but not set up")
        }
    }
    
    // MARK: Constraints
    
    // Cling to top, left, right of self; height of titleLabelDefault
    private func createAndActivateLabelConstraints(label: UILabel, belowView: UIView) {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: belowView,
                           attribute: belowView == self ? .top : .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .top,
                           multiplier: 1,
                           constant: belowView == self ? 0 : -SettingsContentView.paddingBetweenSettings
                         ).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: label,
                                                         height: UILabel.titleLabelHeight).isActive = true
    }
    
    // Place below feature request label ; center horiz in view ; width of this view * 0.8 ;
    // height prettybutton default
    private func createAndActivateContentViewConstraints(contentView: UIView, belowView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: contentView,
                                                         belowView: belowView,
                                                         withPadding: SettingsContentView.paddingBetweenRelatedViews
                                                        ).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: contentView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.8).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: contentView,
                                                         height: PrettyButton.defaultHeight).isActive = true
    }
}

extension SettingsContentView: PrettySegmentedControlDelegate {
    func segmentSelectionChanged(index: Int) {
        setNewColorScheme(ColorScheme(rawValue: index)!)
        
        viewController()?.viewWillLayoutSubviews()
        viewController()?.view?.layoutAllSubviews()
    }
    
}
