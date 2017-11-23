//
//  ExercisesTableViewCell.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/1/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import SwiftCharts

class ExerciseTableViewCell: UITableViewCell, PrettySegmentedControlDelegate {
    
    // MARK: View properties
    
    // delegate we call to show the workout
    public var mainViewCellDelegate: WorkoutSessionStarter?
    // delegate to show a view for us
    public var showViewDelegate: ShowViewDelegate?
    
    // the time amount we're currently displaying
    private var selectedTimeAmount: TimeAmount
    // Filter progressionMethods from graph
    private var filterProgressionMethods: Set<ProgressionMethod>
    // the chart we're showing
    private var chart: Chart?
    
    // The title for every cell
    private var cellTitle: UILabel
    // The exercise associated with each cell
    private var exercise: Exercise?
    // An indicator on whether or not the cell is expanded
    private var expandImage: UIImageView
    // A view we use to select a date view
    private var timeAmountSelectionView: PrettySegmentedControl
    // The view where we'll put the chart
    private var chartFrame: UIView
    // The labels for every exercise
    private var progressionButtons: [ToggleablePrettyButtonWithProgressionMethod]
    // a button that absorbs touches to prevent view from collapsing
    private var invisButton: UIButton
    // The button that allows for exercise editing
    private var editButton: PrettyButton?
    // A button to start the exercise
    private var startExerciseButton: PrettyButton?
    
    // MARK: Init functions
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.cellTitle = UILabel()
        self.expandImage = UIImageView(image: #imageLiteral(resourceName: "DownArrow"))
        self.timeAmountSelectionView = PrettySegmentedControl(labelStrings: TimeAmountArray.map {$0.rawValue},
                                                              frame: .zero)
        self.chartFrame = UIView()
        self.progressionButtons = [ToggleablePrettyButtonWithProgressionMethod]()
        self.invisButton = UIButton()
        
        self.selectedTimeAmount = TimeAmount.ALLTIME
        self.filterProgressionMethods = Set<ProgressionMethod>()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.timeAmountSelectionView.delegate = self
        
        self.addSubview(self.cellTitle)
        self.addSubview(self.expandImage)
        self.addSubview(self.timeAmountSelectionView)
        self.addSubview(self.chartFrame)
        
        self.createAndActivateCellTitleConstraints()
        self.createAndActivateExpandImageConstraints()
        self.createAndActivateTimeAmountSelectionViewConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.filterProgressionMethods.removeAll()
        
        self.clipsToBounds = true
        
        self.cellTitle.textColor = UIColor.niceBlue
        self.cellTitle.textAlignment = .left
        
        self.timeAmountSelectionView.backgroundColor = UIColor.niceRed
        self.chartFrame.clipsToBounds = true
        
        if (self.isSelected) {
            self.editButton?.setDefaultProperties()
            self.editButton?.cornerRadius = 0
            self.editButton?.backgroundColor = UIColor.niceBlue
            self.editButton?.setTitle("Edit", for: .normal)
            
            self.startExerciseButton?.setDefaultProperties()
            self.startExerciseButton?.cornerRadius = 0
            self.startExerciseButton?.backgroundColor = UIColor.niceGreen
            self.startExerciseButton?.setTitle("Start Exercise!", for: .normal)
            
            self.backgroundColor = UIColor.niceLightGray
        } else {
            self.backgroundColor = UIColor.white
        }
        
        super.layoutSubviews()
    }
    
    // MARK: Encapsulated methods
    
    // Set the exercise for this cell
    public func setExercise(exercise: Exercise) {
        self.exercise = exercise
        
        self.cellTitle.text = exercise.getName()
        
        // Remove all dependent views so we don't get duplicates
        self.removeAllExerciseDependentViews()
        
        self.createChart()
        
        self.editButton = PrettyButton()
        self.startExerciseButton = PrettyButton()
        
        self.createAndActivateChartFrameConstraints()
        
        // The last view before these (in terms of top to bottom)
        var prevView: UIView = self.chartFrame
        
        for progressionMethod in exercise.getProgressionMethods() {
            let progressionMethodButton = ToggleablePrettyButtonWithProgressionMethod(
                                                        progressionMethod: progressionMethod,
                                                        frame: .zero)
            progressionMethodButton.setTitle(progressionMethod.getName(), for: .normal)
            progressionMethodButton.setIsToggled(toggled: true)
            progressionMethodButton.setToggleTextColor(color: UIColor.white)
            progressionMethodButton.setDefaultTextColor(color: UIColor.white)
            progressionMethodButton.setToggleViewColor(color:
                getLineColorsForProgressionMethod(progressionMethod: progressionMethod)[0])
            progressionMethodButton.setDefaultViewColor(color: UIColor.niceGray)
            progressionMethodButton.addTarget(self,
                                              action: #selector(toggleButtonPress(sender:)),
                                              for: .touchUpInside)
            self.addSubview(progressionMethodButton)
            
            // Constraints for this exercise label.
            // Place 10 from left/right of the cell
            // Place 10 below above view, height of 20
            
            progressionMethodButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodButton,
                                                                 withCopyView: self,
                                                                 attribute: .centerX).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: progressionMethodButton,
                                                             belowView: prevView,
                                                             withPadding: prevView == self.chartFrame ?
                                                                10 : 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodButton,
                                                                 withCopyView: self,
                                                                 attribute: .width,
                                                                 multiplier: 0.85).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(view: progressionMethodButton,
                                                             height: 40).isActive = true
            
            self.progressionButtons.append(progressionMethodButton)
            prevView = progressionMethodButton
        }
        
        self.editButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        self.startExerciseButton?.addTarget(self, action: #selector(buttonPress(sender:)), for: .touchUpInside)
        
        self.addSubview(editButton!)
        self.addSubview(startExerciseButton!)
        
        self.createAndActivateEditAndStartButtonConstraints(withPrevView: prevView)
        
        self.layoutSubviews()
    }
    
    // Sets the expand button constraints
    public func setExpandable(expandable: Bool) {
        self.expandImage.alpha = expandable ? 1 : 0
    }
    
    // MARK: View functions
    
    // Update selected status; v image becomes ^
    public func updateSelectedStatus() {
        self.expandImage.transform = CGAffineTransform(scaleX: 1, y: self.isSelected ? -1 : 1)
        
        self.layoutIfNeeded()
    }
    
    
    // Remove all views that change (height-wise or data-wise) depending on the exercise
    private func removeAllExerciseDependentViews() {
        for button in self.progressionButtons {
            button.removeFromSuperview()
        }
        progressionButtons.removeAll()
        self.chart?.view.removeFromSuperview()
        self.chart = nil
        self.editButton?.removeFromSuperview()
        self.startExerciseButton?.removeFromSuperview()
    }
    
    private func createChart() {
        self.chart?.view.removeFromSuperview()
        
        self.chart = createChartFromExerciseHistory(exerciseHistory: self.exercise!.getExerciseHistory(),
                                                    filterProgressionMethods: filterProgressionMethods,
                                                    timeAmount: self.selectedTimeAmount,
                                                    frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: self.frame.width * 0.85,
                                                                  height: Chart.defaultHeight))
        self.chartFrame.addSubview(chart!.view)
    }
    
    // MARK: Event functions
    
    @objc private func buttonPress(sender: UIButton) {
        switch(sender) {
        case (startExerciseButton!):
            self.mainViewCellDelegate?.startWorkout(workout: nil, exercise: self.exercise)
        case editButton!:
            self.showViewDelegate?.showView(view: CreateExerciseView(exercise: self.exercise!, frame: .zero))
        default:
            fatalError("Button press not handled in exercisestableview!")
        }
    }
    
    @objc private func toggleButtonPress(sender: ToggleablePrettyButtonWithProgressionMethod) {
        if sender.isToggled {
            filterProgressionMethods.remove(sender.progressionMethod)
        } else {
            filterProgressionMethods.insert(sender.progressionMethod)
        }
        
        self.createChart()
    }
    
    // MARK: PrettySegmentedControlDelegate functions
    
    func segmentSelectionChanged(index: Int) {
        self.selectedTimeAmount = TimeAmountArray[index]
        
        self.createChart()
    }
    
    // MARK: Constraint functions
    
    // Below view top ; indent to left by 10 ; do not overlap expandImage ; height of defaultHeight
    private func createAndActivateCellTitleConstraints() {
        self.cellTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.cellTitle,
                                                             withCopyView: self,
                                                             attribute: .left,
                                                             plusConstant: 10).isActive = true
        NSLayoutConstraint(item: expandImage,
                           attribute: .left,
                           relatedBy: .equal,
                           toItem: cellTitle,
                           attribute: .right,
                           multiplier: 1,
                           constant: 5).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: cellTitle,
                                                         height: UITableViewCell.defaultHeight).isActive = true
    }
    
    // Indent from right ; Below self top ; Width 16 ; Height 8.46
    private func createAndActivateExpandImageConstraints() {
        self.expandImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .right,
                                                             plusConstant: -10).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.expandImage,
                                                             withCopyView: self,
                                                             attribute: .top,
                                                             plusConstant: 20.77).isActive = true
        NSLayoutConstraint.createWidthConstraintForView(view: expandImage,
                                                        width: 16).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: expandImage,
                                                         height: 8.46).isActive = true
    }
    
    // Center horiz in view ; below cellTitle ; width of this view * 0.85 ; height of default
    private func createAndActivateTimeAmountSelectionViewConstraints() {
        self.timeAmountSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.timeAmountSelectionView,
                                                         belowView: self.cellTitle).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.85).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.timeAmountSelectionView,
                                                         height: PrettySegmentedControl.defaultHeight).isActive = true
    }
    
    // Center horiz in view ; Width of this view ; Below cell title ; Height of Chart's default height
    private func createAndActivateChartFrameConstraints() {
        self.chartFrame.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.chartFrame,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.chartFrame,
                                                             withCopyView: self.timeAmountSelectionView,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: self.chartFrame,
                                                         belowView: self.timeAmountSelectionView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: self.chartFrame,
                                                         height: self.exercise!.getProgressionMethods().count > 0 ? Chart.defaultHeight :  0).isActive = true
    }
    
    // Place at bottom of view; take up left, right of view. Height of BaseCellHeight
    private func createAndActivateEditAndStartButtonConstraints(withPrevView: UIView) {
        guard let editButton = self.editButton else {
            fatalError("Edit Button does not exist, but attempted to create constraints.")
        }
        
        // MARK: Edit Button Constraints
        editButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: editButton,
                                                         belowView: withPrevView,
                                                         withPadding: withPrevView == self.chartFrame ?
                                                            0 : 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: editButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton,
                                                             withCopyView: self,
                                                             attribute: .left).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: editButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
        
        
        // MARK: Start exercise button constraints
        
        guard let startButton = self.startExerciseButton else {
            fatalError("Start Exercise button does not exist, but attempted to create constraints.")
        }
        
        self.startExerciseButton?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.createViewBelowViewConstraint(view: startButton,
                                                         belowView: withPrevView,
                                                         withPadding: withPrevView == self.chartFrame ?
                                                            0 : 10).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: startButton,
                                                         height: PrettyButton.defaultHeight).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startButton,
                                                             withCopyView: self,
                                                             attribute: .right).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: startButton,
                                                             withCopyView: self,
                                                             attribute: .width,
                                                             multiplier: 0.5).isActive = true
    }
}

class ToggleablePrettyButtonWithProgressionMethod: ToggleablePrettyButton {
    public var progressionMethod: ProgressionMethod
    
    init(progressionMethod: ProgressionMethod, frame: CGRect) {
        self.progressionMethod = progressionMethod
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
