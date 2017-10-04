//
//  TextFieldWithDefault.swift
//  It's a text field that has a default value.
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class TextFieldWithDefault: UITextField {
    
    // MARK: View properties
    
    // default string in this textfield
    private var defaultString: String?
    private var modified: Bool
    private var userEditing: Bool
    
    // MARK: Inits
    
    init(defaultString: String?, frame: CGRect) {
        self.defaultString = defaultString
        self.modified = false
        self.userEditing = false
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View functions
    
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
    override func textfieldSelected(sender: UITextField) {
        super.textfieldSelected(sender: sender)
        
        self.userEditing = true
        
        if !self.modified {
            self.text = ""
        }
    }
    
    // Determines whether or not the field is modified
    override func textfieldDeselected(sender: UITextField) {
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
                self.textColor = UIColor.black.withAlphaComponent(0.25)
            }
        }
    }
}
