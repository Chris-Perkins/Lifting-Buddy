//
//  WorkoutSummaryTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/22/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class WorkoutSessionSummaryTableViewCell: UITableViewCell {
    
    // MARK: View properties
    
    public static var dateRecorded = Date.init(timeIntervalSince1970: 0)
    
    // The height for the progressionMethod views
    private static let heightPerProgressionMethod: CGFloat = 30
    
    private let cellTitleLabel: UILabel
    private let cellGraphButton: PrettyButton
    private var progressionMethodSummaryViews: [ProgressionMethodSummaryView]
    
    private var exercise: Exercise?
    
    // MARK: View inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        cellTitleLabel = UILabel()
        cellGraphButton = PrettyButton()
        progressionMethodSummaryViews = [ProgressionMethodSummaryView]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        addSubview(cellTitleLabel)
        addSubview(cellGraphButton)
        
        cellGraphButton.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        createAndActivateCellTitleLabelConstraints()
        createAndActivateCellGraphButtonConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Self
        backgroundColor = .primaryBlackWhiteColor
        
        // Cell Title Label
        cellTitleLabel.setDefaultProperties()
        cellTitleLabel.textAlignment = .left
        
        // Graph Button
        cellGraphButton.setDefaultProperties()
        cellGraphButton.setTitle(NSLocalizedString("Button.View", comment: ""), for: .normal)
        
        // PGM Views
        for (index, view) in progressionMethodSummaryViews.enumerated() {
            // We check using bit-level comparison here. This provides a nice alternating
            // background color, making the view much more readable
            view.backgroundColor = UIColor.oppositeBlackWhiteColor.withAlphaComponent(index&1 == 0 ? 0.1 : 0.2)
        }
    }
    
    // MARK: View functions
    
    public static func heightForExercise(exercise: Exercise) -> CGFloat {
        return UITableViewCell.defaultHeight +
            CGFloat(exercise.getProgressionMethods().count) *
            WorkoutSessionSummaryTableViewCell.heightPerProgressionMethod
    }
    
    // Called by tableview to set the exercise
    public func setExercise(exercise: Exercise, withDateRecorded: Date) {
        self.exercise = exercise
        
        deleteProgressionMethodSummaryViews()
        
        cellTitleLabel.text = exercise.getName()
        
        createProgressionMethodSummaryViews(data: getDataForSummaryViews(forExercise: exercise,
                                                                         withDateRecorded: withDateRecorded))
    }
    
    // Gets the progression method, new value, and old value for data based on an exercise.
    private func getDataForSummaryViews(forExercise: Exercise,
                                        withDateRecorded: Date) -> [(ProgressionMethod, Float?, Float?)] {
        // The data we'll be returning
        var returnData = [(ProgressionMethod, Float?, Float?)]()
        
        // A shorter name for easier calls
        let exerciseHistory = forExercise.getExerciseHistory()
        
        /*
            Get the history after the session began.
            We use this data to get the maximum from the workout for display
        */
        let historyAfterSessionBegin = List<ExerciseHistoryEntry>()
                
        for exerciseEntry in exerciseHistory.reversed() {
            
            /*
                If we found something that was not done after the workout began,
                it must not be a part of this workout!
                We break whenever an entry was not in the history
                Bugs can occur here if the user decides that they want to
                move the calendar time up then back to the current date.
                I'm not worried about that possibility for now.
            */
            if exerciseEntry.date!.seconds(from: withDateRecorded) >= 0 {
                historyAfterSessionBegin.append(exerciseEntry)
            } else {
                break
            }
        }
        
        // Get the maximum for the progression methods after the session began.
        let maxForHistoryAfterSessionBegin = ProgressionMethod.getMaxValueForProgressionMethods(fromHistory: historyAfterSessionBegin)
        
        // Just used to map everything out while we iterate.
        // Data will be sent to the cells
        var pgmToNewOldValues = Dictionary<ProgressionMethod, (Float?, Float?)>()
        
        // Initialize every progression method to have a new value, old value deal.
        for pgm in forExercise.getProgressionMethods() {
            pgmToNewOldValues[pgm] = (maxForHistoryAfterSessionBegin[pgm] /* new value */,
                                        pgm.getMaxValue()/* old value */)
        }
        
        for pgm in forExercise.getProgressionMethods() {
            returnData.append((pgm, pgmToNewOldValues[pgm]?.0, pgmToNewOldValues[pgm]?.1))
        }
        
        return returnData
    }
    
    // Creates the progression method data views
    private func createProgressionMethodSummaryViews(data: [(ProgressionMethod, // Progression method
                                                             Float?,          // New data
                                                            Float?)          // Old data
                                                            ]) {
        var prevView: UIView = cellTitleLabel
        
        for dataPiece in data {
            let view = ProgressionMethodSummaryView(progressionMethod: dataPiece.0,
                                                    newValue: dataPiece.1,
                                                    oldValue: dataPiece.2,
                                                    frame: .zero)
            
            addSubview(view)
            progressionMethodSummaryViews.append(view)
            
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
    
    // MARK: Event functions
    
    @objc func buttonPress(sender: PrettyButton) {
        guard let exercise = exercise else {
            fatalError("Exercise wants to be viewed, but was nil")
        }
        (viewContainingController() as? ExerciseDisplayer)?.displayExercise(exercise)
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
        NSLayoutConstraint(item: cellGraphButton,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitleLabel,
                           attribute: .right,
                           multiplier: 1,
                           constant: 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitleLabel,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    private func createAndActivateCellGraphButtonConstraints() {
        cellGraphButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellGraphButton,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellGraphButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellGraphButton,
                                                             withCopyView: cellTitleLabel,
                                                             attribute: .height).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: cellGraphButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 1 - WorkoutSessionSummaryView.newDataLabelWidthOfView - WorkoutSessionSummaryView.pgmLabelWidthOfView
                                                            ).isActive = true
    }
}

// MARK: ProgressionMethodSummaryView class

class ProgressionMethodSummaryView: UIView {
    
    // MARK: View properties
    
    // The progression method associated with this summary
    private let progressionMethod: ProgressionMethod
    // The value just added to the workout
    private let newValue: Float?
    // The old value associated with the workout
    private let oldValue: Float?
    
    // The title label associated with this progressionMethod
    private let titleLabel: UILabel
    // The label that says how much we did in this label
    private let newValueLabel: UILabel
    // Summary results controller
    private let differenceLabel: UILabel
    
    // MARK: View inits
    
    init(progressionMethod: ProgressionMethod, newValue: Float?, oldValue: Float?, frame: CGRect) {
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
            newValueLabel.text = progressionMethod.getDisplayValue(forValue: newValue)
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
                    progressionMethod.getDisplayValue(forValue: newValue - oldValue)
            } else {
                differenceLabel.textColor = .niceGreen
                differenceLabel.backgroundColor = UIColor.niceGreen.withAlphaComponent(0.2)
                differenceLabel.text = progressionMethod.getDisplayValue(forValue: newValue)
            }
        } else {
            differenceLabel.textColor = .niceRed
            differenceLabel.backgroundColor = UIColor.niceRed.withAlphaComponent(0.2)
            differenceLabel.text = NSLocalizedString("SessionView.Label.Skipped", comment: "")
        }
    }
    
    // MARK: Constraint functions
    
    // Cling to left, top, bottom of view ; Width of related multiplier
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
                                                             multiplier: WorkoutSessionSummaryView.pgmLabelWidthOfView,
                                                             plusConstant: -10 * (1/WorkoutSessionSummaryView.pgmLabelWidthOfView)).isActive = true
    }
    
    // Cling to top, bottom ; cling to right of titlelabel ; width of related multiplier
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
                                                             multiplier: WorkoutSessionSummaryView.newDataLabelWidthOfView).isActive = true
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
