//
//  ExerciseButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

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
        addTouchEvents()
        createButtonView()
        createExerciseInfoView()
        
        super.layoutSubviews()
    }
    
    // MARK: View Creation Functions
    
    // The button itself
    private func createButtonView() {
        self.backgroundColor = .white
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.5
        
        /* Testing Exercise to test view work */
        
        self.exercise = Exercise()
        self.exercise?.setName(name: "Testing this view")
        self.exercise?.setRepCount(repCount: 2)
        
        
        // Have to create subview with clipsToBounds = true
        // as otherwise the main button will not have a shadow.
        // Ugly? Yes. Effective? Yes.
        let overlayView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: self.frame.width,
                                               height: self.frame.height))
        overlayView.layer.cornerRadius = 5.0
        overlayView.clipsToBounds = true
        
        //dividingView declaration
        self.dividingView = UIView(frame: CGRect(x: 50,
                                                 y: 0,
                                                 width: 1,
                                                 height: self.frame.height))
        dividingView?.backgroundColor = getNiceBlue()
        overlayView.addSubview(dividingView!)
        
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
        
        self.addSubview(overlayView)
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
    
    // The view that appears below the button
    private func createExerciseInfoView() {
        
    }
    
    // MARK: Function for button behavior
    // Toggle if exercise info is displayed
    private func toggleExerciseInfo() {
        self.exeriseInfoDisplayed ? hideExerciseInfo() : showExerciseInfo()
    }
    
    private func showExerciseInfo() {
        self.exeriseInfoDisplayed = true
    }
    
    private func hideExerciseInfo() {
        self.exeriseInfoDisplayed = false
        
        UIView.animate(withDuration: 0.25, animations: {
            
        })
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
