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
    public var setLabel: UILabel
    // the data stored in each cell (stored as a string)
    private var data: [(ProgressionMethod, String)]
    // the views we're displaying in this cell
    private var displayViews: [UIView]
    
    // MARK: Inits
    
    init(data: [(ProgressionMethod, String)], style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.data = data
        self.setLabel = UILabel()
        self.displayViews = [UIView]()
        
        super.init(style: style, reuseIdentifier: nil)
        
        self.addSubview(setLabel)
        setLabel.setDefaultProperties()
        
        self.createAndActivateSetLabelConstraints()
        self.createAndActivateDataDisplayConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Encapsulated Methods
    
    public func getData() -> [(ProgressionMethod, String)]{
        return self.data
    }
    
    // MARK: Constraints
    
    // Cling to this view ; height of baseHeight
    private func createAndActivateSetLabelConstraints() {
        setLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: self.setLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.setLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .top,
                           relatedBy: .equal,
                           toItem: self.setLabel,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.setLabel,
                                                         height: ExerciseHistoryTableViewCell.baseHeight).isActive = true
    }
    
    // Bind to view; place below the UIView
    private func createAndActivateDataDisplayConstraints() {
        var prevView: UIView = self.setLabel
        
        for dataPiece in data {
            let newView = UILabel()
            newView.text = dataPiece.0.getName()! + ": " + dataPiece.1
            newView.setDefaultProperties()
            newView.font = UIFont.systemFont(ofSize: 18.0)
            
            self.addSubview(newView)
            
            newView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint(item: self,
                               attribute: .left,
                               relatedBy: .equal,
                               toItem: newView,
                               attribute: .left,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: self,
                               attribute: .right,
                               relatedBy: .equal,
                               toItem: newView,
                               attribute: .right,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint(item: prevView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: newView,
                               attribute: .top,
                               multiplier: 1,
                               constant: 0).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: newView,
                                                             height: ExerciseHistoryTableViewCell.heightPerProgressionMethod).isActive = true
            
            prevView = newView
        }
    }
}
