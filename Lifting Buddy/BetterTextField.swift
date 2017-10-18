//
//  BetterTextField.swift
//  It's a text field that has a default value and a label.
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class BetterTextField: UIView{
    
    // MARK: View properties
    
    // Label for this text field
    public var textfield: UITextField
    private var label: UILabel
    
    // default string in this textfield
    private var defaultString: String?
    private var modified: Bool
    private var userEditing: Bool
    private var isNumeric: Bool
    
    // MARK: Inits
    
    init(defaultString: String?, frame: CGRect) {
        self.textfield = UITextField()
        self.label = UILabel()
        
        self.defaultString = defaultString
        self.modified = false
        self.userEditing = false
        self.isNumeric = false
        
        super.init(frame: frame)
        
        self.textfield.setDefaultProperties()
        self.textfield.addTarget(self, action: #selector(editingBegin(sender:)), for: .editingDidBegin)
        self.textfield.addTarget(self, action: #selector(editingEnd(sender:)), for: .editingDidEnd)
        
        self.addSubview(textfield)
        self.addSubview(label)

        self.createAndActivateTextfieldConstraints()
        self.createAndActivateLabelConstraints()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.label.font = UIFont.boldSystemFont(ofSize: 18.0)
        self.label.textAlignment = .center
        self.label.backgroundColor = UIColor.white
        self.label.textColor = UIColor.niceBlue()
        self.label.layer.zPosition = 1
        
        self.textfield.textAlignment = .center
    }
    
    // MARK: View functions
    
    // Sets the label for this view
    
    public func setLabelTitle(title: String?) {
        self.label.text = title
        
        self.createAndActivateLabelConstraints()
    }
    
    public func setIsNumeric(isNumeric: Bool) {
        self.isNumeric = isNumeric
    }
    
    // Returns whether or not this textfield has been modified
    public func getModified() -> Bool {
        return self.modified
    }
    
    public func setDefaultString(defaultString: String?) {
        self.defaultString = defaultString
        
        if !self.modified {
            self.textfield.text = self.defaultString
            
        }
        
        self.layoutSubviews()
    }
    
    // decides whether or not this field was modified
    private func determineIfModified() -> Bool {
        // If the field is empty, the field was not modified.
        let textIsEmpty = self.textfield.text == nil || self.textfield.text == ""
        // valid: if it's not numeric, anything goes. if it is, make sure it's not nil.
        let textIsValid = (!self.isNumeric ||
                            (self.textfield.text?.floatValue != nil ||
                             self.textfield.text?.floatValue != 0))
        
        // this field is modified if it's not empty and if the text is valid
        return !textIsEmpty && textIsValid
    }
    
    // Sets textfield display properties based on self.modified
    private func setTextfieldDisplayProperties() {
        // After determining if modified, modify appropriately
        if self.modified {
            self.textfield.textColor = UIColor.black
        } else {
            self.textfield.text = defaultString
            // black with alpha 0.25 looks like a placeholder.
            // that's why i chose this value.
            self.textfield.textColor = UIColor.black.withAlphaComponent(0.25)
        }
    }
    
    // MARK: View events
    
    // Resets text if the field is modified
    @objc func editingBegin(sender: UITextField) {
        sender.textfieldSelected(sender: sender)
        
        self.userEditing = true
        
        // reset the textfield on user press if not modified
        if !self.modified {
            self.textfield.text = ""
        }
    }
    
    // Determines whether or not the field is modified
    @objc func editingEnd(sender: UITextField) {
        sender.textfieldDeselected(sender: sender)
        
        self.modified = self.determineIfModified()
        
        if self.userEditing {
            self.setTextfieldDisplayProperties()
        }
        
        self.userEditing = false
        
    }
    
    // cling to top, bottom, left of this view. Cling to right of label
    private func createAndActivateTextfieldConstraints() {
        textfield.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: self.textfield,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self.label,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.textfield,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: self.textfield,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.textfield,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
    
    // Cling to right, top, bottom of this view
    private func createAndActivateLabelConstraints() {
        self.label.removeAllSubviews()
        self.addSubview(label)
        
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
        
        if self.label.text != nil && self.label.text != "" {
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: label,
                               attribute: .width,
                               multiplier: 4,
                               constant: 0).isActive = true
        }
    }
}
