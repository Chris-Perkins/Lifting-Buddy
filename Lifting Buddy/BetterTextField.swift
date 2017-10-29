//
//  BetterTextField.swift
//  It's a text field that has a default value and a label.
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class BetterTextField: UIView {
    
    // MARK: View properties
    public var text: String? {
        // return the textfield text if possible; otherwise, return placeholder
        return !(self.textfield.text ?? "").isEmpty ?
            self.textfield.text :
            self.textfield.placeholder
    }
    
    // Label for this text field
    public var textfield: UITextField
    // The label for this view
    private var label: UILabel
    
    // default string in this textfield
    private var defaultString: String?
    // Whether or not this field is modified
    private var modified: Bool
    // Whether or not a user is actively editing this field
    private var userEditing: Bool
    // Whether or not this field is numeric
    private var isNumeric: Bool
    private var curLabelWidthConstraint: NSLayoutConstraint?
    
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
        
        self.textfield.addTarget(self, action: #selector(editingDidEnd(sender:)), for: .editingDidEnd)
        
        self.addSubview(textfield)
        self.addSubview(label)

        self.createAndActivateLabelConstraints()
        self.createAndActivateTextfieldConstraints()
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
        
        self.textfield.placeholder = defaultString
        
        self.textfield.textAlignment = .center
    }
    
    // MARK: Encapsulated methods
    
    // Sets the label for this view
    
    public func setLabelTitle(title: String?) {
        self.label.text = title
        
        self.createAndActivateLabelConstraints()
    }
    
    // Sets if this field is numeric
    public func setIsNumeric(isNumeric: Bool) {
        self.isNumeric = isNumeric
    }
    
    // Returns if this field is numeric
    public func getIsNumeric() -> Bool {
        return self.isNumeric
    }
    
    
    // Returns whether or not this textfield has been modified
    public func getModified() -> Bool {
        return self.modified
    }
    
    // Sets the default string for this textfield
    public func setDefaultString(defaultString: String?) {
        self.textfield.placeholder = defaultString
    }
    
    // MARK: View functions
    
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
    
    // MARK: Event functions
    
    // When the user is done editing
    @objc func editingDidEnd(sender: UITextField) {
        if self.isNumeric {
            if self.textfield.text?.floatValue == nil {
                self.textfield.text = ""
            }
        }
    }
    
    // MARK: Constraints
    
    // cling to top, bottom, left of this view. Cling to right of label
    private func createAndActivateTextfieldConstraints() {
        self.textfield.translatesAutoresizingMaskIntoConstraints = false
        
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
    
    // Cling to right, top, bottom of this view.
    private func createAndActivateLabelConstraints() {
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        curLabelWidthConstraint?.isActive = false
        
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
            curLabelWidthConstraint = NSLayoutConstraint(item: self,
                                                         attribute: .width,
                                                         relatedBy: .equal,
                                                         toItem: label,
                                                         attribute: .width,
                                                         multiplier: 4,
                                                         constant: 0)
        } else {
            curLabelWidthConstraint = NSLayoutConstraint.createWidthConstraintForView(view: self.label,
                                                                                      width: 0)
        }
        
        curLabelWidthConstraint?.isActive = true
    }
}
