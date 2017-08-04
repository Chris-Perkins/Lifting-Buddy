//
//  ExerciseButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// A button / View which displays information about an exercise

import UIKit

// Please create this view with a height of "50" for best results.
// This comes into play when creating the icon view (would prefer a square).

class ExerciseButton: UIView, UIGestureRecognizerDelegate {
    private var exercise: Exercise?
    
    private var iconView: UIView?
    private var dividingView: UIView?
    private var exerciseTitleView: UILabel?
    private var exerciseView: UIView?
    private var exerciseViewOverlay: UIView?
    
    private var exeriseInfoDisplayed: Bool = false
    private var cornerRadius: CGFloat = 5.0
    
    private var viewsCreated: Bool = false
    
    // MARK: View Inits
    init(frame: CGRect, exercise: Exercise) {
        self.exercise = exercise
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Override View functions
    // sets iconView, dividingView, and exerciseTitleView layouts
    override func layoutSubviews() {
        if !viewsCreated {
            addTouchEvents()
            createAndAddButtonView()
            createAndAddExerciseInfoViews()
            self.viewsCreated = true
        }
        super.layoutSubviews()
    }
    
    // MARK: View Creation Functions
    
    // The button itself
    private func createAndAddButtonView() {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.2
        
        // Create overlay for the overlay so we can add shadows without worrying about
        // clipsToBounds = true. Ugly? Yes. Effective? Yes.
        let overlayOverlayView = UIView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: self.frame.width,
                                                      height: self.frame.height))
        overlayOverlayView.backgroundColor = .white
        overlayOverlayView.layer.cornerRadius = cornerRadius
        overlayOverlayView.layer.shadowColor = UIColor.black.cgColor
        overlayOverlayView.layer.shadowOffset = CGSize(width: 0, height: 1)
        overlayOverlayView.layer.shadowOpacity = 0.4
        self.addSubview(overlayOverlayView)
        
        /* Testing Exercise to test view work */
        
        self.exercise = Exercise()
        self.exercise?.setName(name: "Testing this view")
        self.exercise?.setRepCount(repCount: 2)
        
        
        // Add subviews to overlayView. Prevents view from going off of
        // the button.
        let overlayView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: self.frame.width,
                                               height: self.frame.height))
        overlayView.layer.cornerRadius = 5.0
        overlayView.clipsToBounds = true
        
        if exercise != nil {
            // iconView declaration
            self.iconView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: 50,
                                                 height: self.frame.height))
            iconView?.backgroundColor = .lightGray
            // because the button is rounded, clip to bounds
            iconView?.clipsToBounds = true
            overlayView.addSubview(iconView!)
            
            // Create the title view
            self.createTitleView(exercise: exercise!)
            overlayView.addSubview(exerciseTitleView!)
        }
        
        overlayOverlayView.addSubview(overlayView)
    }
    
    // Create the title view for this exercise
    private func createTitleView(exercise: Exercise) {
        // exerciseTitleView declaration
        // - 51 to not go out of bounds
        exerciseTitleView = UILabel(frame: CGRect(x: 51,
                                                  y: 0,
                                                  width: self.frame.width - 51,
                                                  height: self.frame.height))
        exerciseTitleView?.text = exercise.getName()
        exerciseTitleView?.textColor = .black
        exerciseTitleView?.textAlignment = .center
        exerciseTitleView?.numberOfLines = 1
    }
    
    // The view that appears below the button and it's overlay
    private func createAndAddExerciseInfoViews() {
        // Subtract corner radius * 2 so that we display the view from within the flat line
        // of the button.
        // Picture of what this means to be added
        self.exerciseViewOverlay = UIView(frame: CGRect(x: cornerRadius,
                                                        y: self.frame.height - self.cornerRadius,
                                                        width: self.frame.width - cornerRadius * 2,
                                                        height: 0))
        self.exerciseViewOverlay?.clipsToBounds = true
        self.exerciseViewOverlay?.layer.cornerRadius = self.cornerRadius
        self.addSubview(self.exerciseViewOverlay!)
        // Display behind button view
        self.sendSubview(toBack: exerciseViewOverlay!)
        
        let createHeight: CGFloat = 100.0
        self.exerciseView = UIView(frame: CGRect(x: 0,
                                                 y: -createHeight,
                                                 width: (self.exerciseViewOverlay?.frame.width)!,
                                                 height: createHeight))
        self.exerciseView?.backgroundColor = .white
        exerciseViewOverlay?.addSubview(self.exerciseView!)
    }
    
    // MARK: Function for button behavior
    // Toggle exercise info display state
    private func toggleExerciseInfo() {
        self.exeriseInfoDisplayed ? hideExerciseInfo() : showExerciseInfo()
    }
    
    // Show the exercise info view if it exists
    private func showExerciseInfo() {
        if self.exerciseView != nil && self.exerciseViewOverlay != nil {
            self.exeriseInfoDisplayed = true
            
            UIView.animate(withDuration: 0.25, animations: {
                // Slide view down. This creates the illusion of the exerciseView
                // sliding from the button.
                self.exerciseViewOverlay?.frame = CGRect(x: self.cornerRadius,
                                                         y: self.frame.height - self.cornerRadius,
                                                         width: (self.exerciseViewOverlay?.frame.width)!,
                                                         height: (self.exerciseView?.frame.height)!)
                self.exerciseView?.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: (self.exerciseView?.frame.width)!,
                                                  height: (self.exerciseView?.frame.height)!)
            })
        }
    }
    
    // Hide the exercise info view if it exists
    private func hideExerciseInfo() {
        if self.exerciseView != nil && self.exerciseViewOverlay != nil {
            self.exeriseInfoDisplayed = false
            
            UIView.animate(withDuration: 0.25, animations: {
                // Bring overlay view to height 0, main view to -height
                // This creates the illusion of the view sliding into the button
                self.exerciseViewOverlay?.frame = CGRect(x: self.cornerRadius,
                                                         y: self.frame.height - self.cornerRadius,
                                                         width: (self.exerciseViewOverlay?.frame.width)!,
                                                         height: 1)
                self.exerciseView?.frame = CGRect(x: 0,
                                                  y: -(self.exerciseView?.frame.height)!,
                                                  width: (self.exerciseView?.frame.width)!,
                                                  height: (self.exerciseView?.frame.height)!)
            })
        }
    }
    
    // MARK: Button Press Events
    
    // Add Touch Events to this Button
    private func addTouchEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    // Handler for this view pressed
    @objc func buttonPressed(sender: UITapGestureRecognizer? = nil) {
        toggleExerciseInfo()
    }
}
