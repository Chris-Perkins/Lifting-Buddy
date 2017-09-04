//
//  ExpandableButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// A button / View which hides / shows detailed information on click

import UIKit

// Please create this view with a height of "50" for best results.
// This comes into play when creating the icon view (would prefer a square).

class ExpandableButton: UIView, UIGestureRecognizerDelegate {
    
    private var titleView: UILabel?
    private var dropDownView: UIView?
    private var dropDownViewOverlay: UIView?
    // Height constraint for this view
    var heightConstraint: NSLayoutConstraint?
    
    private var dropDownDisplayed: Bool = false
    private var cornerRadius: CGFloat = 5.0
    
    private var viewsCreated: Bool = false
    
    // MARK: View Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: View overrides
    
    // sets iconView, dividingView, and titleView layouts
    override func layoutSubviews() {
        if !viewsCreated {
            addTouchEvents()
            createAndAddButtonView()
            createAndAddDropDownView()
            self.viewsCreated = true
        }
        
        super.layoutSubviews()
    }
    
    // MARK: View Creation Functions
    
    // The button itself
    private func createAndAddButtonView() {
        
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
        
        
        // Add subviews to overlayView. Prevents view from going off of
        // the button (can't do this in normal overlay view or shadow won't work)
        let overlayView = UIView(frame: CGRect(x: 0,
                                               y: 0,
                                               width: self.frame.width,
                                               height: self.frame.height))
        overlayView.layer.cornerRadius = 5.0
        overlayView.clipsToBounds = true
        
        overlayOverlayView.addSubview(overlayView)
    }
    
    // Create the title view for this exercise
    private func createTitleView() {
        // exerciseTitleView declaration
        // - 51 to not go out of bounds
        titleView = UILabel(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: self.frame.width,
                                                  height: self.frame.height))
        titleView?.textColor = .black
        titleView?.textAlignment = .center
        titleView?.numberOfLines = 1
    }
    
    // The view that appears below the button and it's overlay
    private func createAndAddDropDownView() {
        // Subtract corner radius * 2 so that we display the view from within the flat line
        // of the button.
        // Picture of what this means to be added
        self.dropDownViewOverlay = UIView(frame: CGRect(x: cornerRadius,
                                                        y: self.frame.height - self.cornerRadius,
                                                        width: self.frame.width - cornerRadius * 2,
                                                        height: 0))
        self.dropDownViewOverlay?.clipsToBounds = true
        self.dropDownViewOverlay?.layer.cornerRadius = self.cornerRadius
        self.addSubview(self.dropDownViewOverlay!)
        // Display behind button view
        self.sendSubview(toBack: dropDownViewOverlay!)
        
        let createHeight: CGFloat = 100.0
        self.dropDownView = UIView(frame: CGRect(x: 0,
                                                 y: -createHeight,
                                                 width: (self.dropDownViewOverlay?.frame.width)!,
                                                 height: createHeight))
        self.dropDownView?.backgroundColor = .white
        dropDownViewOverlay?.addSubview(self.dropDownView!)
    }
    
    // MARK: Function for button behavior
    
    // Toggle exercise info display state
    private func toggleDropDown() {
        self.dropDownDisplayed ? hideDropDown() : showDropDown()
    }
    
    // Show the exercise info view if it exists
    private func showDropDown() {
        if self.dropDownView != nil && self.dropDownViewOverlay != nil {
            self.dropDownDisplayed = false
            self.titleView?.backgroundColor = UIColor.niceYellow()
            self.titleView?.textColor = UIColor.white
            
            UIView.animate(withDuration: 0.25, animations: {
                // Slide view down. This creates the illusion of the exerciseView
                // sliding from the button.
                self.dropDownViewOverlay?.frame = CGRect(x: self.cornerRadius,
                                                         y: self.frame.height - self.cornerRadius,
                                                         width: (self.dropDownViewOverlay?.frame.width)!,
                                                         height: (self.dropDownView?.frame.height)!)
                self.dropDownView?.frame = CGRect(x: 0,
                                                  y: 0,
                                                  width: (self.dropDownView?.frame.width)!,
                                                  height: (self.dropDownView?.frame.height)!)
                self.heightConstraint?.constant += (self.dropDownView?.frame.height)!
            })
        }
    }
    
    // Hide the exercise info view if it exists
    private func hideDropDown() {
        if self.dropDownView != nil && self.dropDownViewOverlay != nil {
            self.titleView?.backgroundColor = UIColor.white
            self.titleView?.textColor = UIColor.black
            self.dropDownDisplayed = false
            
            UIView.animate(withDuration: 0.25, animations: {
                // Bring overlay view to height 0, main view to -height
                // This creates the illusion of the view sliding into the button
                self.dropDownViewOverlay?.frame = CGRect(x: self.cornerRadius,
                                                         y: self.frame.height - self.cornerRadius,
                                                         width: (self.dropDownViewOverlay?.frame.width)!,
                                                         height: 1)
                self.dropDownView?.frame = CGRect(x: 0,
                                                  y: -(self.dropDownView?.frame.height)!,
                                                  width: (self.dropDownView?.frame.width)!,
                                                  height: (self.dropDownView?.frame.height)!)
            })
            self.heightConstraint?.constant -= (self.dropDownView?.frame.height)!
        }
    }
    
    // MARK: Event functions
    
    // Add Touch Events to this Button
    private func addTouchEvents() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(buttonPressed))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    // Handler for this view pressed
    @objc func buttonPressed(sender: UITapGestureRecognizer? = nil) {
        toggleDropDown()
    }
}
