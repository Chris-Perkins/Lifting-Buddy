//
//  WorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// View which shows information about a workout

import UIKit
import GBVersionTracking

class AboutView: UIView {
    
    // View properties
    
    // The button to create this workout
    private let titleLabel: UILabel
    
    
    override init(frame: CGRect) {
        titleLabel = UILabel()
        
        super.init(frame: frame)
        
        addSubview(titleLabel)
        
        createAndActivateTitleLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel.setDefaultProperties()
        titleLabel.text = "Lifting Buddy v\(GBVersionTracking.currentVersion() ?? "?")"
    }
    
    // MARK: Constraint functions
    
    // Cling to top,left,right of workouttableview ; bottom is self view
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: 50).isActive = true
    }
}

