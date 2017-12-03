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
        isToggled = false
        defaultViewColor = .white
        defaultTextColor = .black
        
        super.init(frame: frame)
        
        backgroundColor = defaultViewColor
        setTitleColor(defaultTextColor, for: .normal)
        
        addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Encapsulated methods
    
    // The view's color when toggled
    public func setToggleViewColor(color: UIColor) {
        toggleViewColor = color
        
        if isToggled {
            backgroundColor = toggleViewColor
        }
    }
    
    // The text's color when toggled
    public func setToggleTextColor(color: UIColor) {
        toggleTextColor = color
        
        if isToggled {
            setTitleColor(toggleTextColor, for: .normal)
        }
    }
    
    // Sets the text when toggled
    public func setToggleText(text: String) {
        toggleText = text
        
        if isToggled {
            setTitle(text, for: .normal)
        }
    }
    
    // The view's color when not toggled
    public func setDefaultViewColor(color: UIColor) {
        defaultViewColor = color
        
        if !isToggled {
            backgroundColor = defaultViewColor
        }
    }
    
    // The view's color when toggled
    public func setDefaultTextColor(color: UIColor) {
        defaultTextColor = color
        
        if !isToggled {
            setTitleColor(defaultTextColor, for: .normal)
        }
    }
    
    // Sets the default text
    public func setDefaultText(text: String) {
        defaultText = text
        
        if !isToggled {
            setTitle(text, for: .normal)
        }
    }
    
    // MARK: View functions
    
    // Sets the view properties to a toggled state
    public func setIsToggled(toggled: Bool) {
        isToggled = toggled
        backgroundColor = toggled ? toggleViewColor : defaultViewColor
        setTitleColor(toggled ? toggleTextColor : defaultTextColor, for: .normal)
        
        // If we toggled to a state that has non-nil text
        if (!toggled && defaultText != nil) || (toggled && toggleText != nil) {
            setTitle(toggled ? toggleText : defaultText, for: .normal)
        }
    }
    
    // MARK: Event functions
    
    @objc public func buttonPress(sender: UIButton) {
        isToggled = !isToggled
        
        UIView.animate(withDuration: animationTimeInSeconds, animations: {
            self.setIsToggled(toggled: self.isToggled)
        })
    }
}
