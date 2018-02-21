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
    public let sessionButton: PrettyButton
    public let workoutsButton: PrettyButton
    public let exercisesButton: PrettyButton
    
    // The view that's currently being selected
    private var selectedView: PrettyButton?
    // Determines if the subviews have been laid out
    private var laidOutSubviews = false
    
    // Width constraints with a session active
    var sessionWidthConstraints = [NSLayoutConstraint]()
    // Width constraints with no session
    var noSessionWidthConstraints = [NSLayoutConstraint]()
    
    
    // MARK: Enums
    
    public enum ContentViews {
        case session
        case workouts
        case exercises
    }
    
    
    // MARK: Init functions
    
    override init(frame: CGRect) {
        sessionButton = PrettyButton()
        workoutsButton = PrettyButton()
        exercisesButton = PrettyButton()
        
        super.init(frame: frame)
        
        addSubview(sessionButton)
        addSubview(workoutsButton)
        addSubview(exercisesButton)
        
        sessionButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        workoutsButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        exercisesButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        createAndActivateButtonConstraints(buttons: [sessionButton,
                                                     workoutsButton,
                                                     exercisesButton])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Session button
        setButtonProperties(button: sessionButton)
        sessionButton.setTitle(NSLocalizedString("Tabs.Session", comment: ""), for: .normal)
        
        // Workouts Button
        workoutsButton.setTitle(NSLocalizedString("Tabs.Workouts", comment: ""), for: .normal)
        setButtonProperties(button: workoutsButton)
        
        // Exercises Button
        exercisesButton.setTitle(NSLocalizedString("Tabs.Exercises", comment: ""), for: .normal)
        setButtonProperties(button: exercisesButton)
        
        // If this is the first time we laid out a subview, press the workout button
        if !laidOutSubviews {
            mainViewController = (viewController() as! MainViewController)
            
            // Only sets properties once.
            laidOutSubviews = true
            
            imitateButtonPress(forButton: workoutsButton)
        }
    }
    
    // MARK: Private functions
    
    // Gives a button default properties, overlay of opacic white, and button press event.
    private func setButtonProperties(button: PrettyButton) {
        if selectedView != button {
            button.setDefaultProperties()
            button.setOverlayColor(color: UIColor.white.withAlphaComponent(0.25))
        }
    }
    
    // Shows the session button
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
    
    // Hides the session button
    public func hideSessionButton() {
        // Animate constraints
        for constraint in sessionWidthConstraints {
            constraint.isActive = false
        }
        for constraint in noSessionWidthConstraints {
            constraint.isActive = true
        }
        UIView.animate(withDuration: 0.5, animations: {
            self.layoutIfNeeded()
        })
        
        // Go to workout view
        imitateButtonPress(forButton: workoutsButton)
    }
    
    // Acts like the workout button was pressed.
    public func imitateButtonPress(forButton button: PrettyButton) {
        buttonPress(sender: button)
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
                viewType = .session
            case workoutsButton:
                viewType = .workouts
            case exercisesButton:
                viewType = .exercises
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
            // The session button is treated differently.
            // At the start, it should not be visible.
            // This means that the session button is always there, but not clickable.
            // It should only be visible when there is an active session.
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
