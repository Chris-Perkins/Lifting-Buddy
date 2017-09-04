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

class WorkoutsView: UIView, CreateWorkoutViewDelegate {
    
    // View properties
    
    var floatyButton: PrettyButton
    var loaded = false
    
    override init(frame: CGRect) {
        floatyButton = PrettyButton()
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        if !loaded {
            floatyButton = PrettyButton(frame: CGRect(x: self.frame.maxX - 100,
                                                      y: self.frame.maxY,
                                                      width: 75,
                                                      height: 75))
            floatyButton.setDefaultProperties()
            floatyButton.cornerRadius = floatyButton.frame.width / 2
            floatyButton.shadowOpacity = 0.2
            floatyButton.setTitle("Create", for: .normal)
            floatyButton.layer.zPosition = 90
            floatyButton.addTarget(self, action: #selector(showCreateWorkoutView(sender:)), for: .touchUpInside)
            
            UIView.animate(withDuration: 0.075, animations: {
                self.floatyButton.frame = CGRect(x: self.frame.maxX - 100,
                                                  y: self.frame.maxY - 100,
                                                  width: 75,
                                                  height: 75)
            })
            self.addSubview(floatyButton)
            
            loaded = true
        } else {
            floatyButton.layoutSubviews()
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Event functions
    
    @objc func showCreateWorkoutView(sender: PrettyButton) {
        floatyButton.isEnabled = false
        
        let createWorkoutView: CreateWorkoutView =
            CreateWorkoutView(frame: CGRect(x: 0,
                                            y: -self.frame.height,
                                            width: self.frame.width,
                                            height: self.frame.height))
        createWorkoutView.layer.zPosition = 100
        createWorkoutView.dataDelegate = self
        self.addSubview(createWorkoutView)
        
        UIView.animate(withDuration: 0.5, animations: {
            createWorkoutView.frame = CGRect(x: 0,
                                             y: self.frame.minY,
                                             width: self.frame.width,
                                             height: self.frame.height)
            
            self.floatyButton.frame = CGRect(x: self.floatyButton.frame.minX,
                                             y: self.frame.maxY + 200,
                                             width: 50,
                                             height: 50)
        })
    }
    
    // MARK: CreateWorkoutViewDelegate methods
    
    func finishedWithWorkout(workout: Workout) {
        // TODO: Realm write new workout
        
        // Recreate floaty button
        self.loaded = false
        self.removeAllSubviews()
        self.layoutSubviews()
    }
}
