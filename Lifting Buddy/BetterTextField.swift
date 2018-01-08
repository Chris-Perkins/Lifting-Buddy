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
        return !(textfield.text ?? "").isEmpty ?
            textfield.text :
            textfield.getPlaceholderString()
        
    }
    
    // Label for this text field
    public let textfield: UITextField
    // The label for this view
    private let label: UILabel
    
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
        textfield = UITextField()
        label = UILabel()
        
        self.defaultString = defaultString
        modified = false
        userEditing = false
        isNumeric = false
        
        super.init(frame: frame)
        
        addSubview(textfield)
        addSubview(label)
        
        createAndActivateLabelConstraints()
        createAndActivateTextfieldConstraints()
        
        textfield.setDefaultProperties()
        textfield.addTarget(self, action: #selector(editingDidEnd(sender:)), for: .editingDidEnd)
        setDefaultString(defaultString: defaultString)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.font = UIFont.boldSystemFont(ofSize: 18.0)
        label.textAlignment = .center
        label.backgroundColor = .lightestBlackWhiteColor
        label.textColor = .niceBlue
        label.layer.zPosition = 1
        
        textfield.textAlignment = .center
        textfield.backgroundColor = .primaryBlackWhiteColor
        textfield.textColor = .oppositeBlackWhiteColor
    }
    
    // MARK: Encapsulated methods
    
    // Sets the label for this view
    
    public func setLabelTitle(title: String?) {
        label.text = title
        
        createAndActivateLabelConstraints()
    }
    
    // Sets if this field is numeric
    public func setIsNumeric(isNumeric: Bool) {
        self.isNumeric = isNumeric
        textfield.keyboardType = isNumeric ? .decimalPad : .default
    }
    
    // Returns if this field is numeric
    public func getIsNumeric() -> Bool {
        return isNumeric
    }
    
    
    // Returns whether or not this textfield has been modified
    public func getModified() -> Bool {
        return modified
    }
    
    // Sets the default string for this textfield
    public func setDefaultString(defaultString: String?) {
        self.defaultString = defaultString
        
        textfield.setPlaceholderString(defaultString)
    }
    
    // MARK: View functions
    
    // decides whether or not this field was modified
    private func determineIfModified() -> Bool {
        // If the field is empty, the field was not modified.
        let textIsEmpty = textfield.text == nil || textfield.text == ""
        // valid: if it's not numeric, anything goes. if it is, make sure it's not nil.
        let textIsValid = (!isNumeric ||
            (textfield.text?.floatValue != nil ||
                textfield.text?.floatValue != 0))
        
        // this field is modified if it's not empty and if the text is valid
        return !textIsEmpty && textIsValid
    }
    
    // MARK: Event functions
    
    // When the user is done editing
    @objc func editingDidEnd(sender: UITextField) {
        if isNumeric {
            if sender.text?.floatValue == nil {
                sender.text = ""
            }
        }
    }
    
    // MARK: Constraints
    
    // cling to top, bottom, left of this view ;  cling to right of label
    private func createAndActivateTextfieldConstraints() {
        textfield.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: textfield,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint(item: label,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: textfield,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: textfield,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: textfield,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
    }
    
    // Cling to right, top, bottom of this view.
    private func createAndActivateLabelConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        
        curLabelWidthConstraint?.isActive = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        
        if label.text != nil && label.text != "" {
            curLabelWidthConstraint =
                NSLayoutConstraint.createViewAttributeCopyConstraint(view: label,
                                                                     withCopyView: self,
                                                                     attribute: .width,
                                                                     multiplier: 1/3)
        } else {
            curLabelWidthConstraint = NSLayoutConstraint.createWidthConstraintForView(view: label,
                                                                                      width: 0)
        }
        
        curLabelWidthConstraint?.isActive = true
    }
}
