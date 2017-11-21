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
        self.pickUnitButton.setTitle(self.progressionMethod?.getUnit() ??
                                    ((self.curSelect >= 0 && self.curSelect < ProgressionMethod.unitList.count) ? ProgressionMethod.unitList[self.curSelect] : "Required: Unit"),
                                     for: .normal)
        
        
        if let unitString = self.progressionMethod?.getUnit() {
            guard let index =  ProgressionMethod.unitList.index(of: unitString.lowercased()) else {
                fatalError("Unable to find unit that supposedly exists...")
            }
            self.curSelect = index
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
    
    // Cling to top, left, bottom of this view ; width of this view * 2/3
    private func createAndActivateNameEntryFieldConstraints() {
        nameEntryField.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 2/3).isActive = true
    }
    
    // Cling to top, right, bottom of this ; Cling to right of nameEntryField
    // AKA: Take up whatever the nameEntryField doesn't.
    private func createAndActivatePickUnitButtonConstraints() {
        pickUnitButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: pickUnitButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.pickUnitButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.pickUnitButton,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint(item: nameEntryField,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: pickUnitButton,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
