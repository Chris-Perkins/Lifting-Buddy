//
//  InputFieldView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/17/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class BetterInputView: UIView {
    
    // MARK: View properties
    
    // The input views in thsi input view
    private var inputViews: [BetterTextField]
    
    // MARK: View inits
    
    // To initialize, pass in list of tuples as: (Label title, defaultString, isNumeric)
    init(args: [(String?,   //label title
                 String?,   // default string
                 Bool       // is field numeric
                )], frame: CGRect) {
        
        inputViews = [BetterTextField]()
        
        super.init(frame: frame)
        
        for arg in args {
            let btf = BetterTextField(defaultString: arg.1, frame: .zero)
            btf.setLabelTitle(title: arg.0)
            btf.setIsNumeric(isNumeric: arg.2)
            
            btf.textfield.setPlaceholderString(arg.1)
            btf.textfield.setDefaultProperties()
            
            inputViews.append(btf)
            addSubview(btf)
        }
        
        self.createAndActivateInputConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Constraints
    
    // Spread evenly across the inputView
    private func createAndActivateInputConstraints() {
        
        var prevView: UIView = self
        
        for view in inputViews {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                                 withCopyView: self,
                                                                 attribute: .top).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                                 withCopyView: self,
                                                                 attribute: .bottom).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == self ? .left : .right,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                                 withCopyView: self,
                                                                 attribute: .width,
                                                                 multiplier: 1/CGFloat(inputViews.count)).isActive = true
            
            prevView = view
        }
    }
}

extension BetterInputView: InputViewHolder {
    // returns the input views
    internal func getInputViews() -> [BetterTextField] {
        return inputViews
    }
    
    // Shows which fields are invalid
    internal func areFieldsValid() -> Bool {
        var returnValue = true
        
        // Go through each view; check if empty
        // if empty, set textfield to red
        for view in inputViews {
            if (view.text ?? "").isEmpty || view.text!.floatValue == nil {
                view.textfield.backgroundColor = .niceRed
                
                returnValue = false
            }
        }
        
        return returnValue
    }
    
    // Just returns the sum of the float values of this field.
    // If you need to do something else, subclass this and override.
    internal func getValue() -> String {
        // -1 indicates something went wrong
        var returnValue: Float = -1
        
        if areFieldsValid() {
            returnValue = 0
            
            for view in inputViews {
                if view.getIsNumeric() {
                    returnValue += view.text!.floatValue!
                }
            }
        }
        
        return String(returnValue)
    }
    
    // Needs to be overriden!
    internal func setDefaultValue(_ value: String?) {
        if inputViews.count > 0 {
            inputViews[0].setDefaultString(defaultString: value)
        } else {
            fatalError("Set default value called when no input views initalized")
        }
    }
    
    internal func clearFields() {
        for view in inputViews {
            view.textfield.text = nil
        }
    }
}
