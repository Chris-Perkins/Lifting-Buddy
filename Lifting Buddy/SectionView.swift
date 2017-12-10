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
    private var sessionButton: PrettyButton?
    private let workoutsButton: PrettyButton
    private let exercisesButton: PrettyButton
    private let aboutButton: PrettyButton
    
    private var selectedView: PrettyButton?
    
    // MARK: Enums
    
    public enum ContentViews {
        case SESSION
        case WORKOUTS
        case EXERCISES
        case ABOUT
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
        
        createAndActivateButtonConstraints(buttons: [workoutsButton, exercisesButton, aboutButton])
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
    
    public func createSessionButton() {
        sessionButton = PrettyButton()
        setButtonProperties(button: sessionButton!)
        sessionButton!.setTitle("session", for: .normal)
        
        createAndActivateButtonConstraints(buttons: [sessionButton!, workoutsButton,
                                                     exercisesButton, aboutButton])
        
        layoutSubviews()
        
        buttonPress(sender: sessionButton!)
    }
    
    public func removeSessionButton() {
        sessionButton?.removeFromSuperview()
        sessionButton = nil
        createAndActivateButtonConstraints(buttons: [workoutsButton, exercisesButton, aboutButton])
    }
    
    // MARK: Event functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    @objc private func buttonPress(sender: PrettyButton) {
        if selectedView != sender {
            selectedView?.backgroundColor = nil
            sender.backgroundColor = .niceYellow
            
            var viewType: SectionView.ContentViews? = nil
            
            switch(sender) {
            case workoutsButton:
                viewType = .WORKOUTS
            case exercisesButton:
                viewType = .EXERCISES
            case aboutButton:
                viewType = .ABOUT
            default:
                if let sessionButton = sessionButton,
                       sender == sessionButton {
                    viewType = .SESSION
                } else {
                    fatalError("User requested view that isn't set up.")
                }
            }
            
            mainViewController?.showContentView(viewType: viewType!)
        }
        
        // Set the newly selected view equal to this button
        selectedView = sender
    }
    
    // Mark: Constraint functions
    
    func createAndActivateButtonConstraints(buttons: [UIButton]) {
        var prevView: UIView = self
        
        // Remove and re-add to remove any assigned constraints.
        for button in buttons {
            button.removeFromSuperview()
            addSubview(button)
        }
        
        // Add constraints
        for button in buttons {
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // If prevView = self, we need to use the left side of the view instead.
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == self ? .left : .right,
                               relatedBy: .equal,
                               toItem: button,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .top).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .bottom).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: button,
                                                                 withCopyView: self,
                                                                 attribute: .width,
                                                                 multiplier: 1/CGFloat(buttons.count)
                                                                ).isActive = true
            
            prevView = button
        }
    }
}
