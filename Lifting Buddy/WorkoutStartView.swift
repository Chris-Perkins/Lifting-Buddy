//
//  WorkoutStartView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/9/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartView: UIView {
    
    // MARK: View properties
    
    private var completeButton: PrettyButton
    
    // MARK: Inits
    
    init(workout: Workout, frame: CGRect) {
        completeButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(completeButton)
        
        // MARK: Complete button properties
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View func overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.niceGray()
        
        completeButton.setDefaultProperties()
        completeButton.setTitle("Finish Workout", for: .normal)
        completeButton.backgroundColor = UIColor.niceGreen()
        
    }
    
    // MARK: Private functions
}
