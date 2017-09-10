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
    private var homeButton: PrettyButton
    private var workoutsButton: PrettyButton
    private var exercisesButton: PrettyButton
    private var settingsButton: PrettyButton
    
    private var selectedView: PrettyButton?
    
    
    // MARK: Enums
    
    public enum ContentViews {
        case HOME
        case WORKOUTS
        case EXERCISES
        case SETTINGS
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        homeButton = PrettyButton()
        workoutsButton = PrettyButton()
        exercisesButton = PrettyButton()
        settingsButton = PrettyButton()
        
        super.init(frame: frame)
        
        self.addSubview(homeButton)
        self.addSubview(workoutsButton)
        self.addSubview(exercisesButton)
        self.addSubview(settingsButton)
        
        self.createAndActivateHomeButtonConstraints()
        self.createAndActivateWorkoutsButtonConstraints()
        self.createAndActivateExercisesButtonConstraints()
        self.createAndActivateSettingsButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.mainViewController = (self.next?.next?.next?.next as! MainViewController)
        
        // Home Button
        homeButton.setTitle("home", for: .normal)
        setButtonProperties(button: homeButton)
        
        // Workouts Button
        workoutsButton.setTitle("workouts", for: .normal)
        setButtonProperties(button: workoutsButton)
        
        
        // Exercises Button
        exercisesButton.setTitle("exercises", for: .normal)
        setButtonProperties(button: exercisesButton)
        
        // Settings Button
        settingsButton.setTitle("settings", for: .normal)
        setButtonProperties(button: settingsButton)
        
        // Start on the today button
        buttonPress(sender: homeButton)
    }
    
    // MARK: Private functions
    
    private func setButtonProperties(button: PrettyButton) {
        button.cornerRadius = 0
        button.setOverlayStyle(style: .FADE)
        button.setOverlayColor(color: UIColor.white.withAlphaComponent(0.25))
        button.addTarget(self, action: #selector(self.buttonPress(sender:)), for: .touchUpInside)
    }
    
    
    // MARK: Event functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    @objc private func buttonPress(sender: PrettyButton) {
        if selectedView != sender {
            selectedView?.backgroundColor = nil
            sender.backgroundColor = UIColor.niceYellow()
            
            var viewType: SectionView.ContentViews? = nil
            
            switch(sender) {
            case (self.homeButton):
                viewType = .HOME
                break
            case (self.workoutsButton):
                viewType = .WORKOUTS
                break
            case (self.exercisesButton):
                viewType = .EXERCISES
                break
            case (self.settingsButton):
                viewType = .SETTINGS
                break
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
    
    // Cling to top, left ; height of this view ; width of this view / 4
    func createAndActivateHomeButtonConstraints() {
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: homeButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: homeButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: homeButton,
                           attribute: .height,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: homeButton,
                           attribute: .width,
                           multiplier: 4,
                           constant: 0).isActive = true
    }
    
    // cling to top of view, right of homeButton ; height of this homebutton ; width of this view / 4
    func createAndActivateWorkoutsButtonConstraints() {
        workoutsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: homeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: workoutsButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: homeButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: workoutsButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: homeButton,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: workoutsButton,
                           attribute: .height,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: workoutsButton,
                           attribute: .width,
                           multiplier: 4,
                           constant: 0).isActive = true
    }
    
    // cling to top of homeButton, right of workoutsButton ; height of exercisesButton ;
    // width of this view / 4
    func createAndActivateExercisesButtonConstraints() {
        exercisesButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: homeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: workoutsButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: homeButton,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .height,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: exercisesButton,
                           attribute: .width,
                           multiplier: 4,
                           constant: 0).isActive = true
    }
    
    // cling to top of homeButton, right of exercisesButton ; height of exercisesButton ;
    // width of this view / 4
    func createAndActivateSettingsButtonConstraints() {
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: homeButton,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: settingsButton,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: exercisesButton,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: settingsButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: homeButton,
                           attribute: .height,
                           relatedBy: .equal,
                           toItem: settingsButton,
                           attribute: .height,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: settingsButton,
                           attribute: .width,
                           multiplier: 4,
                           constant: 0).isActive = true
    }
}
