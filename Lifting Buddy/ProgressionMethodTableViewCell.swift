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
    public var curSelect = -1
    // MARK: View properties
    private var loaded: Bool
    // Whether or not we chose a unit
    private var chosen: Bool
    
    // the progression method we're modifying
    private var progressionMethod: ProgressionMethod? = nil
    
    // the name entry field for this name entry field
    public let nameEntryField: BetterTextField
    // get the pick unit button
    public let pickUnitButton: PrettyButton
    
    // MARK: Init overrides
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        nameEntryField = BetterTextField(defaultString: nil, frame: .zero)
        pickUnitButton = PrettyButton()
        loaded = false
        chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameEntryField)
        addSubview(pickUnitButton)
        
        createAndActivateNameEntryFieldConstraints()
        createAndActivatePickUnitButtonConstraints()
        
        nameEntryField.setDefaultString(defaultString: "Name")
        
        pickUnitButton.addTarget(self,
                                 action: #selector(pickUnitButtonPress(sender:)),
                                 for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        clipsToBounds = true
        backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        pickUnitButton.setDefaultProperties()
    }
    
    // MARK: Custom view functions
    
    // Set associated view properties to the progressionmethod
    public func setProgressionMethod(progressionMethod: ProgressionMethod) {
        self.progressionMethod = progressionMethod
        
        
        nameEntryField.textfield.text = self.progressionMethod?.getName()
        // Determine if the unit exists in our unit list
        pickUnitButton.setTitle(self.progressionMethod?.getUnit() ??
            ((curSelect >= 0 && curSelect < ProgressionMethod.unitList.count) ? ProgressionMethod.unitList[curSelect] : "Set Unit"),
                                for: .normal)
        
        
        if let unitString = self.progressionMethod?.getUnit() {
            guard let index =  ProgressionMethod.unitList.index(of: unitString.lowercased()) else {
                fatalError("Unable to find unit that supposedly exists...")
            }
            curSelect = index
        }
    }
    
    public func saveAndReturnProgressionMethod() -> ProgressionMethod {
        guard let pgm = progressionMethod else  {
            fatalError("ProgressionMethod we were editing or creating is nil!")
        }
        
        pgm.setName(name: nameEntryField.text)
        pgm.setUnit(unit: pickUnitButton.titleLabel?.text)
        
        // If this progression method doesn't have an index, it has not been added to realm
        // so, add this to realm
        if pgm.getIndex() == nil {
            let realm = try! Realm()
            try! realm.write {
                realm.add(pgm)
            }
        }
        
        return pgm
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
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: nameEntryField,
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
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: pickUnitButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: pickUnitButton,
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
