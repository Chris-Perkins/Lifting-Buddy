//
//  SetTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/13/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // IndexPath of this cell in the tableview
    public var indexPath: IndexPath?
    // Delegate we use to change height of cells
    public var delegate: ExerciseTableViewCellDelegate?
    
    // Progression methods for this view
    private var progressionMethods: [ProgressionMethod] = [ProgressionMethod]()
    // Input fields
    private var inputFields: [UITextField] = [UITextField]()
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override public func layoutIfNeeded() {
        for (index, field) in inputFields.enumerated() {
            field.setDefaultProperties()
            field.placeholder = progressionMethods[index].getName()
            field.textAlignment = .left
            field.backgroundColor = UIColor.niceGray()
            field.addTarget(self, action: #selector(textfieldDeselected(sender:)), for: .editingDidEnd)
        }
    }
    
    // MARK: Functions
    
    // Create progression methods
    public func setProgressionMethods(progressionMethods: [ProgressionMethod]) {
        if self.progressionMethods != progressionMethods {
            self.progressionMethods = progressionMethods
            
            self.updateProgressionMethods()
        }
    }
    
    // Update progression methods associated with this view.
    // Create new constraints based on the progression methods
    private func updateProgressionMethods() {
        var prevView: UIView = self
        
        for _ in progressionMethods {
            let field = UITextField()
            
            self.addSubview(field)
            
            field.translatesAutoresizingMaskIntoConstraints = false
            
            if prevView == self {
                NSLayoutConstraint.createViewBelowViewTopConstraint(view: field,
                                                                    belowView: self,
                                                                    withPadding: 10).isActive = true
            } else {
                NSLayoutConstraint.createViewBelowViewConstraint(view: field,
                                                                 belowView: prevView,
                                                                 withPadding: 0).isActive = true
            }
            NSLayoutConstraint.createWidthCopyConstraintForView(view: field,
                                                                withCopyView: self,
                                                                plusWidth: -10).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: field,
                                                             height: 40).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: field,
                               attribute: .left,
                               multiplier: 1,
                               constant: -5).isActive = true
            
            
            self.inputFields.append(field)
            
            prevView = field
        }
    }
    
    @objc private func textfieldDeselected(sender: UITextField) {
        if sender.text != nil && sender.text != "" {
            // Valid float text; we're good
            if sender.text?.floatValue != nil {
                sender.backgroundColor = UIColor.niceLightGreen()
                sender.textColor = UIColor.black
            } // Invalid text, display bad indication
            else {
                sender.backgroundColor = UIColor.niceRed()
                sender.textColor = UIColor.white
                sender.text = ""
            }
        } // Default indication
        else {
            sender.backgroundColor = UIColor.niceGray()
            sender.textColor = UIColor.black
        }
    }
}

// Functions for delegate (the tableview)
protocol ExerciseTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}
