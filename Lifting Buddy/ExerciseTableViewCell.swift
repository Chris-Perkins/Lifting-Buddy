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
    private var inputFields: [ProgressionMethodTextField] = [ProgressionMethodTextField]()
    // Info saved in text fields (used on reload)
    private var savedInfo: [String?] = [String?]()
    
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
        }
    }
    
    // MARK: Functions
    
    // Create progression methods
    public func setProgressionMethods(progressionMethods: [ProgressionMethod]) {
        if self.progressionMethods != progressionMethods {
            inputFields.removeAll()
            savedInfo.removeAll()
            
            self.progressionMethods = progressionMethods
            
            self.updateProgressionMethods()
        } else {
            
        }
    }
    
    // Update progression methods associated with this view.
    // Create new constraints based on the progression methods
    private func updateProgressionMethods() {
        var prevView: UIView = setLabel
        
        for method in progressionMethods {
            let field = ProgressionMethodTextField(progressionMethod: method, frame: .zero)
            
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
            savedInfo.append(nil)
            
            prevView = field
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

// MARK: Protocol Functions for delegate (the tableview)
protocol ExerciseTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}


// MARK: Custom Textfield for this view
class ProgressionMethodTextField: UITextField {
    private var progressionMethod: ProgressionMethod
    // Float value of this cell
    public var floatValueAsString: String?
    
    // MARK: Custom textfield init
    
    init(progressionMethod: ProgressionMethod, frame: CGRect) {
        self.progressionMethod = progressionMethod
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
