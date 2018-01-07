//
//  ExerciseHistoryTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import Realm
import RealmSwift
import UIKit

class ExerciseHistoryTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // the height we need per progressionmethod
    public static let heightPerProgressionMethod: CGFloat = 35.0
    // height for the title bar
    public static let baseHeight: CGFloat = 25
    
    // displays the entry amount
    public let entryNumberLabel: UILabel
    
    // the data stored in each cell (stored as a string)
    private var data: List<RLMExercisePiece>
    // the data we're displaying in this cell
    private var dataDisplayViews: [BetterTextField]
    
    // MARK: Inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        data = List<RLMExercisePiece>()
        entryNumberLabel = UILabel()
        dataDisplayViews = [BetterTextField]()
        
        super.init(style: style, reuseIdentifier: nil)
        
        addSubview(entryNumberLabel)
        entryNumberLabel.setDefaultProperties()
        
        createAndActivateEntryNumberLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        entryNumberLabel.setDefaultProperties()
        
        if !isUserInteractionEnabled {
            for dataDisplayView in dataDisplayViews {
                dataDisplayView.textfield.text = "---"
                dataDisplayView.textfield.backgroundColor = .lightBlackWhiteColor
            }
        }
    }
    
    // MARK: Encapsulated Methods
    
    // Sets the data to be shown in this view ; causes all views to update.
    public func setData(data: List<RLMExercisePiece>) {
        // Removes all data input views
        removeAllSubviews()
        // Re-add as we still want to see the entry label
        addSubview(entryNumberLabel)
        
        createAndActivateEntryNumberLabelConstraints()
        createAndActivateDataDisplayConstraints(withData: data)
    }
    
    // Simply returns out data
    public func getData() -> List<RLMExercisePiece> {
        return data
    }
    
    // MARK: Event functions
    
    // Saves any edited data if it was a successful save
    @objc internal func textFieldEditingEnded(sender: UITextField) {
        // Make sure that the "isNumeric" check ran successfully before we save data.
        // TODO: Determine if this is necessary?
        dataDisplayViews[sender.tag].editingDidEnd(sender: sender)
        
        let realm = try! Realm()
        try! realm.write {
            // Read from the better textfield as it reads the placeholder
            data[sender.tag].value = dataDisplayViews[sender.tag].text
        }
        
    }
    
    // MARK: Constraints
    
    // Cling to this view ; height of baseHeight
    private func createAndActivateEntryNumberLabelConstraints() {
        entryNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: entryNumberLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: entryNumberLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: entryNumberLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: entryNumberLabel,
                                                         height: ExerciseHistoryTableViewCell.baseHeight).isActive = true
    }
    
    // Bind to view; place below the UIView
    // We do this all in one shot to simplify the code a little more.
    private func createAndActivateDataDisplayConstraints(withData data: List<RLMExercisePiece>) {
        self.data = data
        var prevView: UIView = entryNumberLabel
        
        // Since we're creating new views, we should remove all from memory
        dataDisplayViews.removeAll()
        
        // This for loop creates all of the text fields with the associated progression methods to the entry.
        for (index, dataPiece) in data.enumerated() {
            let dataField = BetterTextField(defaultString: dataPiece.value, frame: .zero)
            dataField.setIsNumeric(isNumeric: true)
            dataField.setLabelTitle(title: dataPiece.progressionMethod?.getName())
            
            dataField.textfield.tag = index
            dataField.textfield.addTarget(self,
                                          action: #selector(textFieldEditingEnded(sender:)),
                                          for: .editingDidEnd)
            
            dataDisplayViews.append(dataField)
            
            addSubview(dataField)
            
            /// Progression Method Label Constraints
            // Basically, we cling but have a height of progression method heights.
            // Read the code. That last sentence will make more sense.
            
            dataField.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dataField,
                                                                 withCopyView: self,
                                                                 attribute: .right).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dataField,
                                                                 withCopyView: self,
                                                                 attribute: .left).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: dataField,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: dataField,
                                                             height: ExerciseHistoryTableViewCell.heightPerProgressionMethod
                                                            ).isActive = true
            
            prevView = dataField
        }
    }
}
