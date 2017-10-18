//
//  InputFieldView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/17/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class BetterInputView: UIView, InputViewHolder {
    
    // MARK: View properties
    
    private var inputViews: [BetterTextField]
    
    // MARK: View inits
    
    // To initalize, pass in list of tuples as: (Label title, defaultString, isNumeric)
    init(args: [(String?,   //label title
                 String?,   // default string
                 Bool       // is field numeric
                )], frame: CGRect) {
        
        self.inputViews = [BetterTextField]()
        
        super.init(frame: frame)
        
        for arg in args {
            let btf = BetterTextField(defaultString: arg.1, frame: .zero)
            btf.setLabelTitle(title: arg.0)
            btf.setIsNumeric(isNumeric: arg.2)
            
            btf.textfield.placeholder = arg.1
            btf.textfield.setDefaultProperties()
            
            self.inputViews.append(btf)
            self.addSubview(btf)
        }
        
        self.createAndActivateInputConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: InputViewHolder protocol
    
    // returns the input views
    func getInputViews() -> [BetterTextField] {
        return self.inputViews
    }
    
    // Shows which fields are invalid
    func areFieldsValid() -> Bool {
        var returnValue = true
        
        // Go through each view; check if empty
        // if empty, set textfield to red
        for view in self.inputViews {
            if (view.textfield.text ?? "").isEmpty || view.textfield.text?.floatValue == nil {
                view.textfield.backgroundColor = UIColor.niceRed()
                
                returnValue = false
            }
        }
        
        return returnValue
    }
    
    // MARK: Constraints
    
    // Spread evenly across the inputView
    private func createAndActivateInputConstraints() {
        
        var prevView: UIView = self
        
        for view in inputViews {
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: self,
                               attribute: .top,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .bottom,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: prevView == self ? .left : .right,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .width,
                               relatedBy: .equal,
                               toItem: view,
                               attribute: .width,
                               multiplier: CGFloat(inputViews.count),
                               constant: 0).isActive = true
            
            prevView = view
        }
    }
}
