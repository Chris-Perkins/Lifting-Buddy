//
//  WorkoutStartTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/10/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutStartTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private var exercise: Exercise?
    private var heightConstraint: NSLayoutConstraint?
    public var indexPath: IndexPath?
    public var delegate: WorkoutStartTableViewCellDelegate?
    
    private var cellTitle: UILabel
    
    // MARK: Init Functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitle = UILabel()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellTitle)
        
        //self.createAndActivateCellTitleConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 5
        
        cellTitle.text = exercise?.getName()
    }
    
    // MARK: View functions
    
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
    }
    
    public func updateSelectedStatus() {
        if indexPath != nil {
            delegate?.cellHeightDidChange(height: self.isSelected ? 100 : 50, indexPath: indexPath!)
        }
    }
    
    // MARK: Constraints
    
    private func createAndActivateCellTitleConstraints() {
        cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: cellTitle,
                                                            belowView: self,
                                                            withPadding: 0).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: WorkoutTableView.baseCellHeight).isActive = true
    }
}

protocol WorkoutStartTableViewCellDelegate {
    func cellHeightDidChange(height: CGFloat, indexPath: IndexPath)
}
