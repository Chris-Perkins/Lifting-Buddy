//
//  BetterTextField.swift
//  It's a text field that has a default value and a label.
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class BetterTextField: UITextField {
    
    // MARK: View properties
    
    // Label for this text field
    private var label: UILabel
    
    // default string in this textfield
    private var defaultString: String?
    private var modified: Bool
    private var userEditing: Bool
    
    // MARK: Inits
    
    init(defaultString: String?, frame: CGRect) {
        self.label = UILabel()
        
        self.defaultString = defaultString
        self.modified = false
        self.userEditing = false
        
        super.init(frame: frame)
        
        self.addSubview(label)
        
        self.createAndActivateLabelConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.label.setDefaultProperties()
        self.label.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        self.label.layer.zPosition = 1
    }
    
    // MARK: View functions
    
    // Sets the label for this view
    
    public func setLabelTitle(title: String?) {
        self.label.text = title
        
        self.label.sizeToFit()
        // Add some padding to our label
        self.label.frame = CGRect(x: self.label.frame.minX,
                                  y: self.label.frame.minY,
                                  width: self.label.frame.width + 20,
                                  height: self.label.frame.height)
    }
    
    // Returns whether or not this textfield has been modified
    public func getModified() -> Bool {
        return self.modified
    }
    
    public func setDefaultString(defaultString: String?) {
        self.defaultString = defaultString
        
        if !self.modified {
            self.text = self.defaultString
            self.textColor = UIColor.black.withAlphaComponent(0.25)
        }
    }
    
    // MARK: View events
    
    // Resets text if the field is modified
    @objc override func textfieldSelected(sender: UITextField) {
        super.textfieldSelected(sender: sender)
        
        self.userEditing = true
        
        if !self.modified {
            self.text = ""
        }
    }
    
    // Determines whether or not the field is modified
    @objc override func textfieldDeselected(sender: UITextField) {
        super.textfieldDeselected(sender: sender)
        
        // Determine whether this change is called by a tableview
        // Or if it's being called by the user
        if self.userEditing {
            // If the field is empty, the field was not modified.
            if sender.text == nil || sender.text == "" {
                self.modified = false
                // black with alpha 0.25 looks like a placeholder.
                // that's why i chose this value.
                self.textColor = UIColor.black.withAlphaComponent(0.25)
                self.text = defaultString
            } else {
                self.modified = true
                self.textColor = UIColor.black
            }
            
            self.userEditing = false
        } else {
            if !self.modified {
                self.text = defaultString
                self.textColor = UIColor.black.withAlphaComponent(0.25)
            }
        }
    }
    
    // Cling to right, top, bottom of this view
    private func createAndActivateLabelConstraints() {
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: label,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
