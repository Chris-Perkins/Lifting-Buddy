//
//  CreateWorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/11/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class CreateWorkoutView: UIView {
    
    // View overrides
    
    override func layoutSubviews() {
        let testView: ExerciseButton = ExerciseButton(frame: CGRect(x: 10,
                                                                    y: 10,
                                                                    width: self.frame.width - 20,
                                                                    height: 50), exercise: Exercise())
        self.addSubview(testView)
    }
}
