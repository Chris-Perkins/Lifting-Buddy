//
//  WorkoutSummaryTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/22/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit

class WorkoutSessionSummaryTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    private static let heightPerProgressionMethod: CGFloat = 30
    
    let cellTitleLabel: UILabel
    var progressionMethodSummaryViews: [ProgressionMethodSummaryView]
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.cellTitleLabel = UILabel()
        self.progressionMethodSummaryViews = [ProgressionMethodSummaryView]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.addSubview(self.cellTitleLabel)
        
        self.createAndActivateCellTitleLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.cellTitleLabel.setDefaultProperties()
        self.cellTitleLabel.textAlignment = .left
    }
    
    // MARK: View functions
    
    public static func heightForExercise(exercise: Exercise) -> CGFloat {
        return UITableViewCell.defaultHeight +
            CGFloat(exercise.getProgressionMethods().count) *
            WorkoutSessionSummaryTableViewCell.heightPerProgressionMethod
    }
    
    // Called by tableview to set the exercise
    public func setExercise(exercise: Exercise) {
        self.deleteProgressionMethodSummaryViews()
        
        self.cellTitleLabel.text = exercise.getName()
        self.createProgressionMethodSummaryViews(exercise: exercise)
    }
    
    private func createProgressionMethodSummaryViews(exercise: Exercise) {
        var prevView: UIView = self.cellTitleLabel
        
        for (index, progressionMethod) in exercise.getProgressionMethods().enumerated() {
            let view = ProgressionMethodSummaryView(progressionMethod: progressionMethod,
                                                    newValue: nil,
                                                    oldValue: nil,
                                                    frame: .zero)
            
            self.addSubview(view)
            self.progressionMethodSummaryViews.append(view)
            
            // We check using bit-level comparison here. This provides a nice alternating
            // background color, making the view much more readable
            view.backgroundColor = index&1 == 0 ? UIColor.niceLightGray : UIColor.niceGray
            
            // Then, give it constraints.
            // Cling to left, right of view. place below prevView ; height of default
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewBelowViewConstraint(view: view,
                                                             belowView: prevView).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                                 withCopyView: self,
                                                                 attribute: .left).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: view,
                                                                 withCopyView: self,
                                                                 attribute: .right).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: view,
                                                             height: WorkoutSessionSummaryTableViewCell.heightPerProgressionMethod
                                                             ).isActive = true
            
            prevView = view
        }
    }
    
    private func deleteProgressionMethodSummaryViews() {
        for view in self.progressionMethodSummaryViews {
            view.removeFromSuperview()
        }
        
        self.progressionMethodSummaryViews.removeAll()
    }
    
    // MARK: Constraint functions
    
    private func createAndActivateCellTitleLabelConstraints() {
        self.cellTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.cellTitleLabel,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
}

// MARK: ProgressionMethodSummaryView class

class ProgressionMethodSummaryView: UIView {
    
    // MARK: View properties
    
    // The progression method associated with this summary
    private let progressionMethod: ProgressionMethod
    // The value just added to the workout
    private let newValue: CGFloat?
    // The old value associated with the workout
    private let oldValue: CGFloat?
    
    // The title label associated with this progressionMethod
    private let titleLabel: UILabel
    // Summary results controller
    private let resultsLabel: UILabel
    
    // MARK: View inits
    
    init(progressionMethod: ProgressionMethod, newValue: CGFloat?, oldValue: CGFloat?, frame: CGRect) {
        self.progressionMethod = progressionMethod
        self.newValue = newValue
        self.oldValue = oldValue
        
        self.titleLabel = UILabel()
        self.resultsLabel = UILabel()
        
        super.init(frame: frame)
        
        self.addSubview(self.titleLabel)
        self.addSubview(resultsLabel)
        
        self.createAndActivateTitleLabelConstraints()
        self.createAndActivateResultsLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Title label
        
        self.titleLabel.setDefaultProperties()
        self.titleLabel.font = UIFont.systemFont(ofSize: 18.0)
        self.titleLabel.textAlignment = .left
        self.titleLabel.text = self.progressionMethod.getName()
        
        // Results label
        
        self.resultsLabel.textAlignment = .right
        if let newValue = self.newValue {
            if let oldValue = self.oldValue {
                // Green text color if new > old. Red if less. Blue for equal
                if newValue > oldValue {
                    self.resultsLabel.textColor = UIColor.niceGreen
                } else if newValue < oldValue {
                    self.resultsLabel.textColor = UIColor.niceRed
                } else {
                    self.resultsLabel.textColor = UIColor.niceBlue
                }
                
                self.resultsLabel.text = String(describing: newValue - oldValue)
            } else {
                self.resultsLabel.textColor = UIColor.niceGreen
                self.resultsLabel.text = String(describing: newValue) + " (new!)"
            }
        } else {
            self.resultsLabel.textColor = UIColor.niceRed
            self.resultsLabel.text = "Skipped"
        }
    }
    
    // MARK: Constraint functions
    
    // Cling to left, top, bottom of view ; Width of this view / 2
    private func createAndActivateTitleLabelConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.titleLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // Cling to right, top, bottom of view ; cling to right of titleLabel
    private func createAndActivateResultsLabelConstraints() {
        self.resultsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.resultsLabel,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.resultsLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.resultsLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint(item: self.titleLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: self.resultsLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
