//
//  WorkoutTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 9/4/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private var label: UILabel
    private var workout: Workout?
    private var expandImage: UIImageView
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label = UILabel()
        expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(label)
        self.addSubview(expandImage)
        
        // MARK: Label constraints
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: label,
                                                            belowView: self,
                                                            withPadding: 5).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: label,
                           attribute: .left,
                           multiplier: 1,
                           constant: -10).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: label, width: 150).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: label,
                                                         height: 40).isActive = true
        
        // MARK: Image constraints
        expandImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage, width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage, height: 8.46).isActive = true
        NSLayoutConstraint.createViewBelowViewTopConstraint(view: expandImage,
                                                            belowView: self,
                                                            withPadding: 20.77).isActive = true
        NSLayoutConstraint(item: self,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: expandImage,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        self.backgroundColor = UIColor.white
        self.clipsToBounds = true
        self.layer.cornerRadius = 5.0
        label.textAlignment = .left
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    public func setWorkout(workout: Workout) {
        self.workout = workout
        
        label.text = workout.getName()
        label.textColor = UIColor.niceBlue()
    }
    
    public func getWorkout() -> Workout? {
        return self.workout
    }
    
    public func getHeight() -> CGFloat {
        return self.frame.height
    }
    
    public func setHeight(height: CGFloat) {
        self.frame.size.height = height
    }
    
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
    }
}
