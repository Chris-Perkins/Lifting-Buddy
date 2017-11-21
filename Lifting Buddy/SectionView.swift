//
//  SectionView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/20/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Sections shown on the bottom of the header view

import UIKit

class SectionView: UIView {
    // MARK: View properties
    
    // Required view for modifying sectionContentView
    var mainViewController: MainViewController?
    // Our sections
    private var workoutsButton: PrettyButton
    private var exercisesButton: PrettyButton
    
    private var selectedView: PrettyButton?
    
    
    // MARK: Enums
    
    public enum ContentViews {
        case WORKOUTS
        case EXERCISES
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        workoutsButton = PrettyButton()
        exercisesButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(workoutsButton)
        self.addSubview(exercisesButton)
        
        self.createAndActivateWorkoutsButtonConstraints()
        self.createAndActivateExercisesButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO:... FIX THIS ABOMINATION. if possible.
        self.mainViewController = (self.next?.next?.next?.next as! MainViewController)
        
        // Workouts Button
        workoutsButton.setTitle("workouts", for: .normal)
        setButtonProperties(button: workoutsButton)
        
        // Exercises Button
        exercisesButton.setTitle("exercises", for: .normal)
        setButtonProperties(button: exercisesButton)
        
        // Start on the workout screen
        buttonPress(sender: workoutsButton)
    }
    
    // MARK: Private functions
    
    private func setButtonProperties(button: PrettyButton) {
        button.setDefaultProperties()
        button.setOverlayColor(color: UIColor.white.withAlphaComponent(0.25))
        button.addTarget(self, action: #selector(self.buttonPress(sender:)), for: .touchUpInside)
    }
    
    
    // MARK: Event functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    @objc private func buttonPress(sender: PrettyButton) {
        if self.selectedView != sender {
            self.selectedView?.backgroundColor = nil
            sender.backgroundColor = UIColor.niceYellow
            
            var viewType: SectionView.ContentViews? = nil
            
            switch(sender) {
            case (self.workoutsButton):
                viewType = .WORKOUTS
            case (self.exercisesButton):
                viewType = .EXERCISES
            default:
                print("User pressed a button that doesn't exist?")
                exit(0)
            }
            
            mainViewController?.showContentView(viewType: viewType!)
        }
        
        // Set the newly selected view equal to this button
        selectedView = sender
    }
    
    // Mark: Constraint functions
    
    // cling to top of view, right of homeButton ; height of this homebutton ; width of this view / 4
    func createAndActivateWorkoutsButtonConstraints() {
        self.workoutsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // cling to top of homeButton, right of workoutsButton ; height of exercisesButton ;
    // width of this view / 4
    func createAndActivateExercisesButtonConstraints() {
        exercisesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self.workoutsButton,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: workoutsButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self.workoutsButton,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
}
