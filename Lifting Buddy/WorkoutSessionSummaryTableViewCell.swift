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
    
    public static var dateRecorded = Date.init(timeIntervalSince1970: 0)
    
    // The height for the progressionMethod views
    private static let heightPerProgressionMethod: CGFloat = 30
    
    private let cellTitleLabel: UILabel
    private var progressionMethodSummaryViews: [ProgressionMethodSummaryView]
    
    // MARK: View inits
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        cellTitleLabel = UILabel()
        progressionMethodSummaryViews = [ProgressionMethodSummaryView]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(cellTitleLabel)
        
        createAndActivateCellTitleLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellTitleLabel.setDefaultProperties()
        cellTitleLabel.textAlignment = .left
    }
    
    // MARK: View functions
    
    public static func heightForExercise(exercise: Exercise) -> CGFloat {
        return UITableViewCell.defaultHeight +
            CGFloat(exercise.getProgressionMethods().count) *
            WorkoutSessionSummaryTableViewCell.heightPerProgressionMethod
    }
    
    // Called by tableview to set the exercise
    public func setExercise(exercise: Exercise, withDateRecorded: Date) {
        deleteProgressionMethodSummaryViews()
        
        cellTitleLabel.text = exercise.getName()
        
        createProgressionMethodSummaryViews(data: getDataForSummaryViews(forExercise: exercise,
                                                                         withDateRecorded: withDateRecorded))
    }
    
    // Gets the progression method, new value, and old value for data based on an exercise.
    private func getDataForSummaryViews(forExercise: Exercise,
                                        withDateRecorded: Date) -> [(ProgressionMethod, CGFloat?, CGFloat?)] {
        // The data we'll be returning
        var returnData = [(ProgressionMethod, CGFloat?, CGFloat?)]()
        
        // A shorter name for easier calls
        let exerciseHistory = forExercise.getExerciseHistory()
        
        // The newest entry (the one we should have just entered...)
        var newestEntry: ExerciseHistoryEntry? = nil
        // The previous entry to the newest one (second to last)
        var prevEntryToNewest: ExerciseHistoryEntry? = nil
        
        // Check if there's even history to access so we don't go out of bounds below.
        if exerciseHistory.count >= 1 {
            // If the exercise info was submitted when the workout first began (withDateRecorded is that value),
            // we assume this is an exercise we're attempting to access.
            // Otherwise, we skipped this workout.
            if exerciseHistory[exerciseHistory.count - 1].date!.seconds(from: withDateRecorded) >= 0 {
                newestEntry = exerciseHistory[exerciseHistory.count - 1]
                
                for exerciseEntry in exerciseHistory.reversed() {
                    // If we found something that was not done in the past few seconds
                    // it must be our previous entry!
                    // (small bugs can occur here. Don't think about it too hard.)
                    if exerciseEntry.date!.seconds(from: withDateRecorded) <= 0 {
                        prevEntryToNewest = exerciseEntry
                        break
                    }
                }
            }
            
        }
        
        // Just used to map everything out while we iterate.
        var dict = Dictionary<ProgressionMethod, (CGFloat?, CGFloat?)>()
        
        // Initialize every progression method to have a new value, old value deal.
        for progressionMethod in forExercise.getProgressionMethods() {
            dict[progressionMethod] = (nil /* new value */, nil /* old value */)
        }
        
        // TODO: Fetch maximum value per progressionMethod
        if newestEntry != nil {
            for entryPiece in newestEntry!.exerciseInfo {
                dict[entryPiece.progressionMethod!]!.0 = CGFloat(entryPiece.value!.floatValue!)
            }
            
            if prevEntryToNewest != nil {
                for entryPiece in prevEntryToNewest!.exerciseInfo {
                    dict[entryPiece.progressionMethod!]!.1 = CGFloat(entryPiece.value!.floatValue!)
                }
            }
        }
        
        for pgm in forExercise.getProgressionMethods() {
            returnData.append((pgm, dict[pgm]!.0, dict[pgm]!.1))
        }
        
        return returnData
    }
    
    // Creates the progression method data views
    private func createProgressionMethodSummaryViews(data: [(ProgressionMethod, // Progression method
        CGFloat?,          // New data
        CGFloat?)          // Old data
        ]) {
        var prevView: UIView = cellTitleLabel
        
        for (index, dataPiece) in data.enumerated() {
            let view = ProgressionMethodSummaryView(progressionMethod: dataPiece.0,
                                                    newValue: dataPiece.1,
                                                    oldValue: dataPiece.2,
                                                    frame: .zero)
            
            addSubview(view)
            progressionMethodSummaryViews.append(view)
            
            // We check using bit-level comparison here. This provides a nice alternating
            // background color, making the view much more readable
            view.backgroundColor = index&1 == 0 ? .niceLightGray : .niceGray
            
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
    
    // Deletes progression methods views
    private func deleteProgressionMethodSummaryViews() {
        for view in progressionMethodSummaryViews {
            view.removeFromSuperview()
        }
        
        progressionMethodSummaryViews.removeAll()
    }
    
    // MARK: Constraint functions
    
    private func createAndActivateCellTitleLabelConstraints() {
        cellTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellTitleLabel,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitleLabel,
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
    // The label that says how much we did in this label
    private let newValueLabel: UILabel
    // Summary results controller
    private let differenceLabel: UILabel
    
    // MARK: View inits
    
    init(progressionMethod: ProgressionMethod, newValue: CGFloat?, oldValue: CGFloat?, frame: CGRect) {
        self.progressionMethod = progressionMethod
        self.newValue = newValue
        self.oldValue = oldValue
        
        titleLabel = UILabel()
        newValueLabel = UILabel()
        differenceLabel = UILabel()
        
        super.init(frame: frame)
        
        addSubview(titleLabel)
        addSubview(newValueLabel)
        addSubview(differenceLabel)
        
        createAndActivateTitleLabelConstraints()
        createAndActivateNewValueLabelConstraints()
        createAndActivateDifferenceLabelConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View functions
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Title label
        
        titleLabel.setDefaultProperties()
        titleLabel.font = UIFont.systemFont(ofSize: 18.0)
        titleLabel.textAlignment = .left
        titleLabel.text = progressionMethod.getName()
        
        // NewValue & Difference label
        
        differenceLabel.textAlignment = .center
        newValueLabel.textAlignment = .center
        
        if let newValue = newValue {
            newValueLabel.textColor = .niceBlue
            newValueLabel.text = String(describing: newValue)
            newValueLabel.backgroundColor = UIColor.niceLightBlue.withAlphaComponent(0.2)
            
            if let oldValue = oldValue {
                // Green text color if new > old. Red if less. Blue for equal
                if newValue > oldValue {
                    differenceLabel.textColor = .niceGreen
                    differenceLabel.backgroundColor = UIColor.niceGreen.withAlphaComponent(0.2)
                } else if newValue < oldValue {
                    differenceLabel.textColor = .niceRed
                    differenceLabel.backgroundColor = UIColor.niceRed.withAlphaComponent(0.2)
                } else {
                    differenceLabel.textColor = .niceBlue
                    differenceLabel.backgroundColor = UIColor.niceBlue.withAlphaComponent(0.2)
                }
                
                // Add a "+" char to symbolize that we gained some weight
                differenceLabel.text = (newValue >= oldValue ? "+" : "") +
                    String(describing: newValue - oldValue)
            } else {
                differenceLabel.textColor = .niceGreen
                differenceLabel.backgroundColor = UIColor.niceGreen.withAlphaComponent(0.2)
                differenceLabel.text = String(describing: newValue)
            }
        } else {
            differenceLabel.textColor = .niceRed
            differenceLabel.backgroundColor = UIColor.niceRed.withAlphaComponent(0.2)
            differenceLabel.text = "Skipped"
        }
    }
    
    // MARK: Constraint functions
    
    // Cling to left, top, bottom of view ; Width of this view / 2
    private func createAndActivateTitleLabelConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: titleLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
    
    // Cling to top, bottom ; cling to right of titlelabel ; width of this view * 0.25
    private func createAndActivateNewValueLabelConstraints() {
        newValueLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: newValueLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: newValueLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint(item: titleLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: newValueLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: newValueLabel,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.25).isActive = true
    }
    
    // Cling to right, top, bottom of view ; cling to right of newresultlabel
    private func createAndActivateDifferenceLabelConstraints() {
        differenceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: differenceLabel,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: differenceLabel,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: differenceLabel,
                                                             withCopyView: self,
                                                             attribute: .bottom).isActive = true
        NSLayoutConstraint(item: newValueLabel,
                           attribute: .right,
                           relatedBy: .equal,
                           toItem: differenceLabel,
                           attribute: .left,
                           multiplier: 1,
                           constant: 0).isActive = true
    }
}
