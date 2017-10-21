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
    
    public static let heightPerProgressionMethod: CGFloat = 25
    public static let baseHeight: CGFloat = 25
    
    private var data: [String]
    private var displayViews: [UIView]
    public var setLabel: UILabel
    
    // MARK: Inits
    
    init(data: [String], style: UITableViewCellStyle, reuseIdentifier: String?) {
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
            newView.text = dataPiece
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
