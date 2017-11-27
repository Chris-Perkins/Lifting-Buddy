//
//  SelectablePrettyButton.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/23/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ToggleablePrettyButton: PrettyButton {
    
    // MARK: View properties
    
    public var isToggled: Bool
    
    // Toggle text (string)
    private var toggleText: String?
    // The color when toggled
    private var toggleViewColor: UIColor?
    // The text color when toggled
    private var toggleTextColor: UIColor?
    
    // Sets default text
    private var defaultText: String?
    // The default color (untoggled)
    private var defaultViewColor: UIColor
    // The default text color (untoggled)
    private var defaultTextColor: UIColor
    
    // MARK: View inits
    
    override init(frame: CGRect) {
        self.isToggled = false
        self.defaultViewColor = .white
        self.defaultTextColor = .black
        
        super.init(frame: frame)
        
        self.backgroundColor = self.defaultViewColor
        self.setTitleColor(self.defaultTextColor, for: .normal)
        
        self.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Encapsulated methods
    
    // The view's color when toggled
    public func setToggleViewColor(color: UIColor) {
        self.toggleViewColor = color
        
        if self.isToggled {
            self.backgroundColor = self.toggleViewColor
        }
    }
    
    // The text's color when toggled
    public func setToggleTextColor(color: UIColor) {
        self.toggleTextColor = color
        
        if self.isToggled {
            self.setTitleColor(self.toggleTextColor, for: .normal)
        }
    }
    
    // Sets the text when toggled
    public func setToggleText(text: String) {
        self.toggleText = text
        
        if self.isToggled {
            self.setTitle(text, for: .normal)
        }
    }
    
    // The view's color when not toggled
    public func setDefaultViewColor(color: UIColor) {
        self.defaultViewColor = color
        
        if !self.isToggled {
            self.backgroundColor = self.defaultViewColor
        }
    }
    
    // The view's color when toggled
    public func setDefaultTextColor(color: UIColor) {
        self.defaultTextColor = color
        
        if !self.isToggled {
            self.setTitleColor(self.defaultTextColor, for: .normal)
        }
    }
    
    // Sets the default text
    public func setDefaultText(text: String) {
        self.defaultText = text
        
        if !self.isToggled {
            self.setTitle(text, for: .normal)
        }
    }
    
    // MARK: View functions
    
    // Sets the view properties to a toggled state
    public func setIsToggled(toggled: Bool) {
        self.isToggled = toggled
        self.backgroundColor = toggled ? self.toggleViewColor : self.defaultViewColor
        self.setTitleColor(toggled ? self.toggleTextColor : self.defaultTextColor, for: .normal)
        
        // If we toggled to a state that has non-nil text
        if (!toggled && self.defaultText != nil) || (toggled && toggleText != nil) {
            self.setTitle(toggled ? self.toggleText : self.defaultText, for: .normal)
        }
    }
    
    // MARK: Event functions
    
    @objc public func buttonPress(sender: UIButton) {
        self.isToggled = !self.isToggled
        
        UIView.animate(withDuration: animationTimeInSeconds, animations: {
            self.setIsToggled(toggled: self.isToggled)
        })
    }
}
