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
    
    // Set Count Label
    private var setLabel: UILabel
    // Progression methods for this view
    private var progressionMethods: [ProgressionMethod] = [ProgressionMethod]()
    // Input fields
    private var inputFields: [UITextField] = [UITextField]()
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        setLabel = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(setLabel)
        
        self.createAndActivateSetLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override public func layoutIfNeeded() {
        self.setLabel.setDefaultProperties()
        self.setLabel.text = "Set " + String(indexPath!.row)
        
        for (index, field) in inputFields.enumerated() {
            field.setDefaultProperties()
            field.placeholder = progressionMethods[index].getName()
            field.textAlignment = .left
            field.backgroundColor = UIColor.niceGray().withAlphaComponent(0.5)
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
        var prevView: UIView = setLabel
        
        for _ in progressionMethods {
            let field = UITextField()
            
            self.addSubview(field)
            
            field.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewBelowViewConstraint(view: field,
                                                             belowView: prevView,
                                                             withPadding: 0).isActive = true
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
    
    // MARK: View constraints
    
    // MARK: Constraint functions
    
    private func createAndActivateSetLabelConstraints() {
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: setLabel,
                                                            belowView: self,
                                                            withPadding: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setLabel,
                                                         height: 30).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: setLabel,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: setLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}

// Functions for delegate (the tableview)
protocol ExerciseTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}
