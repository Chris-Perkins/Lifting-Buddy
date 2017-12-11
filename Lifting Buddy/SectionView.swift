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
    private var sessionButton: PrettyButton
    private let workoutsButton: PrettyButton
    private let exercisesButton: PrettyButton
    private let aboutButton: PrettyButton
    
    // The view that's currently being selected
    private var selectedView: PrettyButton?
    
    // Width constraints with a session active
    var sessionWidthConstraints = [NSLayoutConstraint]()
    // Width constraints with no session
    var noSessionWidthConstraints = [NSLayoutConstraint]()
    
    
    // MARK: Enums
    
    public enum ContentViews {
        case SESSION
        case WORKOUTS
        case EXERCISES
        case ABOUT
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        sessionButton = PrettyButton()
        workoutsButton = PrettyButton()
        exercisesButton = PrettyButton()
        aboutButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(sessionButton)
        addSubview(workoutsButton)
        addSubview(exercisesButton)
        addSubview(aboutButton)
        
        createAndActivateButtonConstraints(buttons: [sessionButton,
                                                     workoutsButton,
                                                     exercisesButton,
                                                     aboutButton])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mainViewController = (viewController() as! MainViewController)
        
        // Session button
        setButtonProperties(button: sessionButton)
        sessionButton.setTitle("session", for: .normal)
        
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
    
    public func showSessionButton() {
        for constraint in noSessionWidthConstraints {
            constraint.isActive = false
        }
        for constraint in sessionWidthConstraints {
            constraint.isActive = true
        }
        UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            })
        
        
        layoutSubviews()
        
        buttonPress(sender: sessionButton)
    }
    
    public func hideSessionButton() {
        for constraint in sessionWidthConstraints {
            constraint.isActive = false
        }
        for constraint in noSessionWidthConstraints {
            constraint.isActive = true
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
    }
    
    // MARK: Event functions
    
    // Called by the event handlers to send a call to the main view controller to display view
    @objc private func buttonPress(sender: PrettyButton) {
        if selectedView != sender {
            selectedView?.backgroundColor = nil
            sender.backgroundColor = .niceYellow
            
            var viewType: SectionView.ContentViews? = nil
            
            switch(sender) {
            case sessionButton:
                viewType = .SESSION
            case workoutsButton:
                viewType = .WORKOUTS
            case exercisesButton:
                viewType = .EXERCISES
            case aboutButton:
                viewType = .ABOUT
            default:
                fatalError("User requested view that isn't set up.")
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
            if button == sessionButton {
                let constraint = NSLayoutConstraint.createWidthConstraintForView(view: button,
                                                                                 width: 0)
                
                constraint.isActive = true
                noSessionWidthConstraints.append(constraint)
                
            } else {
                let constraint = NSLayoutConstraint.createViewAttributeCopyConstraint(
                    view: button,
                    withCopyView: self,
                    attribute: .width,
                    multiplier: 1/CGFloat(buttons.count - 1)
                )
                
                constraint.isActive = true
                noSessionWidthConstraints.append(constraint)
            }
            sessionWidthConstraints.append(NSLayoutConstraint.createViewAttributeCopyConstraint(
                                                            view: button,
                                                            withCopyView: self,
                                                            attribute: .width,
                                                            multiplier: 1/CGFloat(buttons.count)
                                                        )
            )
            
            prevView = button
        }
    }
}
