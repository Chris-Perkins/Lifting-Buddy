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
    private let workoutsButton: PrettyButton
    private let exercisesButton: PrettyButton
    private let aboutButton: PrettyButton
    
    private var selectedView: PrettyButton?
    
    // MARK: Enums
    
    public enum ContentViews {
        case WORKOUTS
        case EXERCISES
        case HELP
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        workoutsButton = PrettyButton()
        exercisesButton = PrettyButton()
        aboutButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(workoutsButton)
        addSubview(exercisesButton)
        addSubview(aboutButton)
        
        createAndActivateWorkoutsButtonConstraints()
        createAndActivateExercisesButtonConstraints()
        createAndActivateHelpButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TODO:... FIX THIS ABOMINATION. if possible.
        mainViewController = (next?.next?.next?.next as! MainViewController)
        
        // Workouts Button
        workoutsButton.setTitle("workouts", for: .normal)
        setButtonProperties(button: workoutsButton)
        
        // Exercises Button
        exercisesButton.setTitle("exercises", for: .normal)
        setButtonProperties(button: exercisesButton)
        
        // Home button
        aboutButton.setTitle("about", for: .normal)
        setButtonProperties(button: aboutButton)
        
        // Start on the workout screen
        buttonPress(sender: workoutsButton)
    }
    
    // MARK: Private functions
    
    private func setButtonProperties(button: PrettyButton) {
        button.setDefaultProperties()
        button.setOverlayColor(color: UIColor.white.withAlphaComponent(0.25))
        button.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    
    // MARK: Event functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    @objc private func buttonPress(sender: PrettyButton) {
        if selectedView != sender {
            selectedView?.backgroundColor = nil
            sender.backgroundColor = .niceYellow
            
            var viewType: SectionView.ContentViews? = nil
            
            switch(sender) {
            case (workoutsButton):
                viewType = .WORKOUTS
            case (exercisesButton):
                viewType = .EXERCISES
            case (aboutButton):
                viewType = .HELP
            default:
                print("User pressed button that isn't set up")
                exit(0)
            }
            
            mainViewController?.showContentView(viewType: viewType!)
        }
        
        // Set the newly selected view equal to this button
        selectedView = sender
    }
    
    // Mark: Constraint functions
    
    // cling to top of view, right of homeButton ; height of this homebutton ; width of this view / 3
    func createAndActivateWorkoutsButtonConstraints() {
        workoutsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .height).isActive = true
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: workoutsButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1/3).isActive = true
    }
    
    // cling to top of homeButton, right of workoutsButton ; height of exercisesButton ;
    // width of this view / 3
    func createAndActivateExercisesButtonConstraints() {
        exercisesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exercisesButton,
                                                             withCopyView: workoutsButton,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: workoutsButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exercisesButton,
                                                             withCopyView: workoutsButton,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: exercisesButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1/3).isActive = true
    }
    
    // Cling to top ; left clings to right of exercisesButton ; height of thisView ;
    // width of this view / 3
    func createAndActivateHelpButtonConstraints() {
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: exercisesButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: aboutButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: self,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: aboutButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1/3).isActive = true
    }
}
