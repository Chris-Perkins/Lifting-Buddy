//
//  ProgressionsMethodTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/15/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class ProgressionMethodTableViewCell: UITableViewCell {
    
    // The currently selected progressionMethod
    private var curSelect = -1
    // MARK: View properties
    private var loaded: Bool
    // Whether or not we chose a unit
    private var chosen: Bool
    
    // the progression method we're modifying
    var progressionMethod: ProgressionMethod? = nil
    
    // the name entry field for this name entry field
    var nameEntryField: BetterTextField
    // get the pick unit button
    var pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.nameEntryField = BetterTextField(defaultString: nil, frame: .zero)
        self.pickUnitButton = PrettyButton()
        self.loaded = false
        self.chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(nameEntryField)
        self.addSubview(pickUnitButton)
        
        self.createAndActivateNameEntryFieldConstraints()
        self.createAndActivatePickUnitButtonConstraints()
        
        self.nameEntryField.setDefaultString(defaultString: "Name")
        
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
        
        self.clipsToBounds = true
        self.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        // MARK: Pick Unit button
        
        self.pickUnitButton.setDefaultProperties()
    }
    
    // MARK: Custom view functions
    
    public func setProgressionMethod(progressionMethod: ProgressionMethod) {
        self.progressionMethod = progressionMethod
        
        self.nameEntryField.textfield.text = self.progressionMethod?.getName()
        self.pickUnitButton.setTitle(self.progressionMethod?.getName() ?? "Required: Unit", for: .normal)
        
        // Checks 'reps'; an old unit. Don't crash unnecessarily.
        if self.progressionMethod?.getUnit() != nil && self.progressionMethod?.getUnit() != "Reps" {
            guard let index: Int =  ProgressionMethod.unitList.index(of: (self.progressionMethod?.getUnit()!)!) else {
                fatalError("Unable to find unit that supposedly exists...")
            }
            self.curSelect = index
        } else if self.progressionMethod?.getUnit() == "Reps" {
            // Replace reps with any unit.
            // The app has only been distributed to 1 person, so no data migration.
            self.progressionMethod?.setUnit(unit: ProgressionMethod.unitList[0])
        }
    }
    
    public func saveAndReturnProgressionMethod() -> ProgressionMethod {
        guard let _ = self.progressionMethod else  {
            fatalError("ProgressionMethod we were editing or creating is nil!")
        }
        
        self.progressionMethod!.setName(name: self.nameEntryField.text)
        self.progressionMethod!.setUnit(unit: self.pickUnitButton.titleLabel?.text)
        
        // If this progression method doesn't have an index, it has not been added to realm
        // so, add this to realm
        if self.progressionMethod!.getIndex() == nil {
            let realm = try! Realm()
            try! realm.write {
                realm.add(self.progressionMethod!)
            }
        }
        
        return self.progressionMethod!
    }
    
    // MARK: Event functions
    
    // Cycles through the unit
    @objc func pickUnitButtonPress(sender: UIButton) {
        // reset if modified
        pickUnitButton.setDefaultProperties()
        
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
                           multiplier: 7/4,
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
