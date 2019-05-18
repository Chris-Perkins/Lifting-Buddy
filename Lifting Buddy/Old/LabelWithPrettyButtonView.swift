//
//  LabelWithPrettyButtonView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/24/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//
// Simply a label with a button in a view.
// Created to standardize this type of UI Type throughout the program.

import UIKit

class LabelWithPrettyButtonView: UIView {
    
    // MARK: View properties
    
    private static let widthMultiplierForLabel: CGFloat = 2/3
    
    public let label = UILabel()
    public let button = PrettyButton()
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpViews()
    }
    
    
    // Adds subviews, creates constraints
    private func setUpViews() {
        addSubview(label)
        addSubview(button)
        
        createAndActivateLabelConstraints()
        createAndActivateButtonConstraints()
    }
    
    // MARK: Constraints
    
    
    // Cling to top, left, bottom of self. Width of self * (2/3)
    private func createAndActivateLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: LabelWithPrettyButtonView.widthMultiplierForLabel).isActive = true
    }
    
    // Cling to top, bottom, right of self. Cling left to label's right
    private func createAndActivateButtonConstraints() {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: button,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true

    }
}
