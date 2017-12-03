//
//  ExerciseHistoryTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 10/21/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class ExerciseHistoryTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    // the height we need per progressionmethod
    public static let heightPerProgressionMethod: CGFloat = 25
    // height for the title bar
    public static let baseHeight: CGFloat = 25
    
    // displays the set title
    public let setLabel: UILabel
    
    // the data stored in each cell (stored as a string)
    private var data: [(ProgressionMethod, String)]
    // the views we're displaying in this cell
    private var displayViews: [UIView]
    
    // MARK: Inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        data = [(ProgressionMethod, String)]()
        setLabel = UILabel()
        displayViews = [UIView]()
        
        super.init(style: style, reuseIdentifier: nil)
        
        addSubview(setLabel)
        setLabel.setDefaultProperties()
        
        createAndActivateSetLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Encapsulated Methods
    
    public func setData(data: [(ProgressionMethod, String)]) {
        removeAllSubviews()
        addSubview(setLabel)
        createAndActivateSetLabelConstraints()
        createAndActivateDataDisplayConstraints(withData: data)
    }
    
    public func getData() -> [(ProgressionMethod, String)] {
        return data
    }
    
    // MARK: Constraints
    
    // Cling to this view ; height of baseHeight
    private func createAndActivateSetLabelConstraints() {
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setLabel,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: setLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: setLabel,
                                                         height: ExerciseHistoryTableViewCell.baseHeight).isActive = true
    }
    
    // Bind to view; place below the UIView
    private func createAndActivateDataDisplayConstraints(withData: [(ProgressionMethod, String)]) {
        data = withData
        var prevView: UIView = setLabel
        
        for dataPiece in withData {
            let progressionMethodLabel = UILabel()
            displayViews.append(progressionMethodLabel)
            
            progressionMethodLabel.text = dataPiece.0.getName()!
            progressionMethodLabel.setDefaultProperties()
            progressionMethodLabel.font = UIFont.systemFont(ofSize: 18.0)
            
            let dataLabel = UILabel()
            displayViews.append(dataLabel)
            dataLabel.textColor = UIColor.black.withAlphaComponent(0.25)
            dataLabel.text = dataPiece.1
            dataLabel.textAlignment = .center
            
            addSubview(progressionMethodLabel)
            addSubview(dataLabel)
            
            progressionMethodLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodLabel,
                                                                 withCopyView: self,
                                                                 attribute: .right).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodLabel,
                                                                 withCopyView: self,
                                                                 attribute: .width,
                                                                 multiplier: 0.5).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: progressionMethodLabel,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: progressionMethodLabel,
                                                             height: ExerciseHistoryTableViewCell.heightPerProgressionMethod
                ).isActive = true
            
            dataLabel.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dataLabel,
                                                                 withCopyView: self,
                                                                 attribute: .left).isActive = true
            NSLayoutConstraint(item: progressionMethodLabel,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: dataLabel,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dataLabel,
                                                                 withCopyView: progressionMethodLabel,
                                                                 attribute: .top).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: dataLabel,
                                                                 withCopyView: progressionMethodLabel,
                                                                 attribute: .bottom).isActive = true
            
            prevView = progressionMethodLabel
        }
    }
}
