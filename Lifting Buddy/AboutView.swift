//
//  AboutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 12/2/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import GBVersionTracking

class AboutView: UIScrollView {
    
    // MARK: Properties
    
    let titleLabel: UILabel
    
    // MARK: Inits
    
    override init(frame: CGRect) {
        titleLabel = UILabel()
        
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        
        createAndActivateTitleLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        titleLabel = UILabel()
        
        super.init(coder: aDecoder)
        
        addSubview(titleLabel)
        
        createAndActivateTitleLabelConstraints()
    }
    
    // MARK: View function overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = UIColor.niceGray
        
        titleLabel.setDefaultProperties()
        titleLabel.text = "Lifting Buddy v\(GBVersionTracking.currentVersion())"
        
        contentSize.height = titleLabel.frame.maxY + 20
    }
    
    // MARK: Constraint functions
    
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: titleLabel,
                                                         height: 50).isActive = true
    }
}
