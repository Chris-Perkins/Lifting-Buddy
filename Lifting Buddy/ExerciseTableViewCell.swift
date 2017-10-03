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
        super.layoutIfNeeded()
        
        self.setLabel.setDefaultProperties()
        self.setLabel.text = "Set " + String(self.indexPath!.row + 1)
        
        for (_, field) in inputFields.enumerated() {
            field.setDefaultProperties()
            field.textAlignment = .left
        }
    }
    
    // MARK: Functions
    
    // Create progression methods
    public func setExercise(exercise: Exercise) {
        let progressionMethods = exercise.getProgressionMethods().toArray()
        
        if self.progressionMethods != progressionMethods {
            inputFields.removeAll()
            savedInfo.removeAll()
            
            self.progressionMethods = progressionMethods
            
            self.updateProgressionMethods(withRepCount: exercise.getRepCount())
        }
    }
    
    // Update progression methods associated with this view.
    // Create new constraints based on the progression methods
    private func updateProgressionMethods(withRepCount: Int) {
        var prevView: UIView = setLabel
        
        let repField = NamedTextField(withName: "Rep Count", frame: .zero)
        
        if withRepCount != 0 {
            repField.text = String(withRepCount)
        }
        
        self.addSubview(repField)
        self.attachConstraintsToEntryView(entryView: repField, belowView: prevView)
        
        self.inputFields.append(repField)
        
        prevView = repField
        
        
        for method in progressionMethods {
            let field = NamedTextField(withName: method.getName()!, frame: .zero)
            
            self.addSubview(field)
            self.attachConstraintsToEntryView(entryView: field, belowView: prevView)
            
            self.inputFields.append(field)
            
            prevView = field
        }
    }
    
    private func attachConstraintsToEntryView(entryView: UIView, belowView: UIView) {
        entryView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewConstraint(view: entryView,
                                                         belowView: belowView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: entryView,
                                                            withCopyView: self,
                                                            plusWidth: -10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: entryView,
                                                         height: 40).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: entryView,
                           attribute: .left,
                           multiplier: 1,
                           constant: -5).isActive = true
    }
    
    // MARK: Constraint functions
    
    // cling to left ; place below setLabel ; height of 30 ; width of this view
    private func createAndActivateSetLabelConstraints() {
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: setLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: setLabel,
                                                            belowView: self,
                                                            withPadding: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setLabel,
                                                         height: 30).isActive = true
        NSLayoutConstraint.createWidthCopyConstraintForView(view: setLabel,
                                                            withCopyView: self,
                                                            plusWidth: 0).isActive = true
    }
}

// MARK: Protocol Functions for delegate (the tableview)
protocol ExerciseTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
    
    func cellCompleteStatusChanged(complete: Bool)
}


// MARK: Custom Textfield for this view
class NamedTextField: UITextField {
    private var name: String
    // Float value of this cell
    public var floatValueAsString: String?
    public var bgDefault = UIColor.niceGray().withAlphaComponent(0.5)
    
    // MARK: Custom textfield init
    
    init(withName: String, frame: CGRect) {
        self.name = withName
        
        super.init(frame: frame)
        
        self.backgroundColor = bgDefault
        self.placeholder = withName
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // Reset background color
    override func textfieldDeselected(sender: UITextField) {
        super.textfieldDeselected(sender: sender)
        
        sender.backgroundColor = self.bgDefault
    }

}
