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
    
    let closeButton: PrettyButton
    
    // MARK: Init methods
    
    init(withExercises: List<Exercise>) {
        closeButton = PrettyButton()
        
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.niceBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Close button
        self.closeButton.setDefaultProperties()
        self.closeButton.setTitle("Return to Main View",
                                  for: .normal)
    }
    
    private func createAndActivateCloseButtonConstraints() {
        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.closeButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.closeButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        
    }
}
