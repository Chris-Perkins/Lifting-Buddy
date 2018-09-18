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
import ClingConstraints

class ProgressionMethodTableViewCell: UITableViewCell {
    
    
    
    // MARK: View properties
    
    /// Whether or not this view loaded
    private var loaded: Bool
    /// Whether or not we chose a unit
    private var chosen: Bool
    
    /// The constraints for when we're picking a progression method
    private var pickingProgressionMethodConstraints = [NSLayoutConstraint]()
    
    /// The constraints for when we're not picking a progression method
    private var notPickingProgressionMethodConstraints = [NSLayoutConstraint]()
    
    /// The buttons used for unit selection
    private var unitSelectionButtons = [PrettyButton]()
    
    /// the progression method we're modifying
    private var progressionMethod: ProgressionMethod? = nil
    
    /// the name entry field for this name entry field
    public let nameEntryField: BetterTextField
    /// The pickUnitButton
    public let pickUnitButton: PrettyButton
    
    
    // MARK: Init overrides
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        nameEntryField = BetterTextField(defaultString: nil, frame: .zero)
        pickUnitButton = PrettyButton()
        loaded = false
        chosen = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameEntryField)
        addSubview(pickUnitButton)
        
        createUnitSelectionButtonsAndConstraints()
        createAndActivateNameEntryFieldConstraints()
        createAndActivatePickUnitButtonConstraints()
        
        nameEntryField.setDefaultString(defaultString: NSLocalizedString("Button.Name", comment: ""))
        
        pickUnitButton.addTarget(self,
                                 action: #selector(pickUnitButtonPress(sender:)),
                                 for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        clipsToBounds = true
        backgroundColor = .lightBlackWhiteColor
        
        pickUnitButton.setDefaultProperties()
        pickUnitButton.backgroundColor = isUserInteractionEnabled ? .niceBlue : .lightBlackWhiteColor
    }
    
    // MARK: Custom view functions
    
    /// Set associated view properties to the progressionmethod
    public func setProgressionMethod(progressionMethod: ProgressionMethod) {
        self.progressionMethod = progressionMethod
        
        nameEntryField.textfield.text = self.progressionMethod?.getName()
        // Determine if the unit exists in our unit list
        pickUnitButton.setTitle(self.progressionMethod?.getUnit() ??
                NSLocalizedString("EditExerciseView.Button.SetUnit", comment: ""),
                                for: .normal)
        nameEntryField.textfield.text = self.progressionMethod?.getName()
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
            pgm.setDefaultValue(defaultValue: nameEntryField.text)
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(pgm)
            }
        }
        
        return pgm
    }
    
    // MARK: Event functions
    
    /// Cycles through the unit
    @objc func pickUnitButtonPress(sender: UIButton) {
        // reset if modified
        pickUnitButton.setDefaultProperties()
        
        setPickingUnitMode(true)
    }
    
    /**
     Should be called whenever a unit was selected.
     
     - Parameter sender: The unit selection button that was pressed
    */
    @objc func unitSelectionButtonPress(sender: UIButton) {
        // Update the name field's default str if the field has not been modified
        nameEntryField.setDefaultString(defaultString: sender.currentTitle)
        // Sets
        pickUnitButton.setTitle(sender.currentTitle, for: .normal)
        
        setPickingUnitMode(false)
    }
    
    /**
     Sets the current mode for picking a unit
     
     - Parameter pickingUnits: Should be true if we should enter the picking unit mode; false otherwise.
    */
    private func setPickingUnitMode(_ pickingUnits: Bool) {
        if (pickingUnits) {
            notPickingProgressionMethodConstraints.deactivateAllConstraints()
            pickingProgressionMethodConstraints.activateAllConstraints()
        } else {
            pickingProgressionMethodConstraints.deactivateAllConstraints()
            notPickingProgressionMethodConstraints.activateAllConstraints()
        }
        
        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: Constraints
    
    /// Creates and activates the unit button constraints.
    private func createUnitSelectionButtonsAndConstraints() {
        for unitName in ProgressionMethod.Unit.allCases.reversed() {
            let unitButton = PrettyButton()
            self.addSubview(unitButton)
            unitButton.addTarget(self, action: #selector(unitSelectionButtonPress(sender:)),
                                 for: .touchUpInside)
            
            unitButton.setDefaultProperties()
            unitButton.setTitle(unitName.rawValue, for: .normal)
            unitButton.copy(.top, .bottom, of: self)
            unitButton.titleLabel?.minimumScaleFactor = 0.5
            unitButton.titleLabel?.adjustsFontSizeToFitWidth = true
            unitSelectionButtons.append(unitButton)
            
            notPickingProgressionMethodConstraints.append(unitButton.copy(.right, of: self))
            notPickingProgressionMethodConstraints.append(unitButton.setWidth(0))
        }
        // Deactivate, create new constraints, then activate to avoid layout errors.
        notPickingProgressionMethodConstraints.deactivateAllConstraints()
        
        pickingProgressionMethodConstraints.append(contentsOf:
            self.fill(.rightToLeft, withViews: unitSelectionButtons, withSpacing: 0))
        pickingProgressionMethodConstraints.deactivateAllConstraints()
        notPickingProgressionMethodConstraints.activateAllConstraints()
        
    }
    
    /// Cling to top, left, bottom of this view ; width of this view * 2/3
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
    
    /// Cling to top, right, bottom of this ; Cling to right of nameEntryField
    /// AKA: Take up whatever the nameEntryField doesn't.
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
