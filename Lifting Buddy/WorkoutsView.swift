//
//  WorkoutView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// View which shows information about a workout

import UIKit

import RealmSwift
import Realm

class WorkoutsView: UIView {
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        let floatyButton: PrettyButton = PrettyButton(frame: CGRect(x: self.frame.maxX - 100,
                                                                    y: self.frame.maxY - 100,
                                                                    width: 75,
                                                                    height: 75))
        floatyButton.backgroundColor = UIColor.niceBlue()
        floatyButton.setOverlayStyle(style: .BLOOM)
        floatyButton.cornerRadius = floatyButton.frame.width / 2
        floatyButton.shadowOpacity = 0.5
        floatyButton.setOverlayColor(color: UIColor.niceYellow())
        floatyButton.setTitle("Create", for: .normal)
        floatyButton.layer.zPosition = 1
        floatyButton.addTarget(self, action: #selector(showCreateWorkoutView(sender:)), for: .touchUpInside)
        
        self.addSubview(floatyButton)
        
        super.layoutSubviews()
    }
    
    // MARK: Event functions
    
    @objc func showCreateWorkoutView(sender: PrettyButton) {
    
    }
    
    func showExercises() {
        /*for exercise in (self.workout?.getExercises())! {
            
        }*/
    }
}
