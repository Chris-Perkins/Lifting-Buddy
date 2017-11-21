//
//  WorkoutSessionSummaryScreen.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class WorkoutSessionSummaryScreen: UIView {
    
    // MARK: View properties
    
    // A button the user should press if we're trying to close this view
    let closeButton: PrettyButton
    
    // MARK: Init methods
    
    init(withExercises: List<Exercise>) {
        self.closeButton = PrettyButton()
        
        super.init(frame: .zero)
        
        self.addSubview(closeButton)
        
        self.closeButton.addTarget(self,
                                   action: #selector(buttonPress(sender:)),
                                   for: .touchUpInside)
        
        self.createAndActivateCloseButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // This view's layout
        self.backgroundColor = UIColor.niceGray
        
        // Close button
        self.closeButton.setDefaultProperties()
        self.closeButton.setTitle("Return to Main View",
                                  for: .normal)
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch sender {
        case self.closeButton:
            self.removeSelfNicelyWithAnimation()
        default:
            fatalError("Button pressed that was not set up")
        }
    }
    
    // MARK: Constraint Functions
    
    private func createAndActivateCloseButtonConstraints() {
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.closeButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.closeButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.closeButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.closeButton,
                                                         height: 50).isActive = true
        
    }
}
