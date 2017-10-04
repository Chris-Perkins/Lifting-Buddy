//
//  ProgressionsMethodTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ProgressionMethodTableViewCell: UITableViewCell {
    
    private var curSelect = -1
    
    // MARK: View properties
    private var loaded: Bool
    private var chosen: Bool
    var nameEntryField: TextFieldWithDefault
    var pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.nameEntryField = TextFieldWithDefault(defaultString: nil, frame: .zero)
        self.pickUnitButton = PrettyButton()
        self.loaded = false
        self.chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameEntryField)
        self.addSubview(pickUnitButton)
        
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivatePickUnitButtonConstraints()
        
        self.pickUnitButton.setTitle("Required: Unit", for: .normal)
        self.pickUnitButton.addTarget(self,
                                      action: #selector(pickUnitButtonPress(sender:)),
                                      for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        self.nameEntryField.setDefaultProperties()
        self.nameEntryField.placeholder = "Required: Name"
        
        // MARK: Pick Unit button
        
        self.pickUnitButton.setDefaultProperties()
    }
    
    // MARK: Event functions
    
    @objc func pickUnitButtonPress(sender: UIButton) {
        curSelect = (curSelect + 1) % ProgressionMethod.unitList.count
        
        pickUnitButton.setTitle(ProgressionMethod.unitList[curSelect], for: .normal)
        
        // Update the name field's default str if the field has not been modified
        nameEntryField.setDefaultString(defaultString: ProgressionMethod.unitList[curSelect])
    }
    
    // MARK: Constraints
    
    // Cling to top, left, bottom of this view ; width of this view * 2 / 3 (66%)
    private func createAndActivateNameEntryFieldConstraints() {
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: nameEntryField,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: nameEntryField,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: nameEntryField,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .width,
                           relatedBy: .equal,
                           toItem: nameEntryField,
                           attribute: .width,
                           multiplier: 3/2,
                           constant: 0).isActive = true
    }
    
    // Cling to top, right, bottom of this ; Cling to right of nameEntryField
    // AKA: Take up whatever the nameEntryField doesn't.
    private func createAndActivatePickUnitButtonConstraints() {
        pickUnitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: pickUnitButton,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: pickUnitButton,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: pickUnitButton,
                           attribute: .bottom,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: nameEntryField,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: pickUnitButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
