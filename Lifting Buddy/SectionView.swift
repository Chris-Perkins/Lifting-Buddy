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
        self.workoutsButton = PrettyButton()
        self.exercisesButton = PrettyButton()
        self.aboutButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(self.workoutsButton)
        self.addSubview(self.exercisesButton)
        self.addSubview(self.aboutButton)
        
        self.createAndActivateWorkoutsButtonConstraints()
        self.createAndActivateExercisesButtonConstraints()
        self.createAndActivateHelpButtonConstraints()
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
        self.workoutsButton.setTitle("workouts", for: .normal)
        self.setButtonProperties(button: workoutsButton)
        
        // Exercises Button
        self.exercisesButton.setTitle("exercises", for: .normal)
        self.setButtonProperties(button: exercisesButton)
        
        // Home button
        self.aboutButton.setTitle("about", for: .normal)
        self.setButtonProperties(button: self.aboutButton)
        
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
            case (self.aboutButton):
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
                                                             multiplier: 1/3).isActive = true
    }
    
    // cling to top of homeButton, right of workoutsButton ; height of exercisesButton ;
    // width of this view / 3
    func createAndActivateExercisesButtonConstraints() {
        self.exercisesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self.workoutsButton,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: self.workoutsButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.exercisesButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self.workoutsButton,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.exercisesButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1/3).isActive = true
    }
    
    // Cling to top ; left clings to right of exercisesButton ; height of thisView ;
    // width of this view / 3
    func createAndActivateHelpButtonConstraints() {
        self.aboutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.aboutButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: self.exercisesButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.aboutButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.aboutButton,
                                                             withCopyView: self,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.aboutButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1/3).isActive = true
    }
}
