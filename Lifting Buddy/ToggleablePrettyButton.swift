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
    
    private var toggleViewColor: UIColor?
    private var toggleTextColor: UIColor?
    private var defaultViewColor: UIColor
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
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        self.isToggled = !self.isToggled
        
        UIView.animate(withDuration: animationTimeInSeconds, animations: {
            self.backgroundColor = self.isToggled ? self.toggleViewColor : self.defaultViewColor
            self.setTitleColor(self.isToggled ? self.toggleTextColor : self.defaultTextColor, for: .normal) 
        })
    }
}
