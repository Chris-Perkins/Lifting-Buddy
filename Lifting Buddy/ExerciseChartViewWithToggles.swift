//
//  ExerciseChartViewWithToggles.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/22/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import SwiftCharts

public class ExerciseChartViewWithToggles: UIView, PrettySegmentedControlDelegate {
    
    // MARK: View properties
    private static let heightPerProgressionMethodButton: CGFloat = 40.0
    
    // The exercise we're graphing
    private let exercise: Exercise
    // the amount of space the chart can take up width-wise
    private let chartWidth: CGFloat
    // A view we use to select a date view
    private let timeAmountSelectionView: PrettySegmentedControl
    // The view where we'll put the chart
    private let chartFrame: UIView
    
    // Filter progressionMethods from graph
    private var filterProgressionMethods: Set<ProgressionMethod>
    // the time amount we're currently displaying
    private var selectedTimeAmount: TimeAmount
    // the chart we're showing
    private var chart: Chart?
    // The labels for every exercise
    private var progressionButtons: [ToggleablePrettyButtonWithProgressionMethod]
    
    // MARK: Inits
    init(exercise: Exercise, chartWidth: CGFloat) {
        self.exercise = exercise
        self.chartWidth = chartWidth
        
        selectedTimeAmount = TimeAmount.MONTH
        filterProgressionMethods = Set<ProgressionMethod>()
        
        timeAmountSelectionView = PrettySegmentedControl(labelStrings: TimeAmountArray.map {$0.rawValue},
                                                         frame: .zero)
        chartFrame = UIView()
        progressionButtons = [ToggleablePrettyButtonWithProgressionMethod]()
        
        super.init(frame: .zero)
        
        timeAmountSelectionView.delegate = self
        
        addSubview(timeAmountSelectionView)
        addSubview(chartFrame)
        
        createAndActivateTimeAmountSelectionViewConstraints()
        createAndActivateChartFrameConstraints()
        createProgressionMethodFilterButtons()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
        backgroundColor = .niceRed
        
        chartFrame.clipsToBounds = true
        
        filterProgressionMethods.removeAll()
        
        chartFrame.backgroundColor = .niceRed
    }
    
    // MARK: Custom view functions
    
    /*
     Every progression method gets a button of some height (lines 1 + 2)
     Also, every graph needs a time selection view and the chart height (line 3)
     Totals up to what this return statement says.
     */
    static func getNecessaryHeightForExerciseGraph(exercise: Exercise) -> CGFloat {
        return CGFloat(exercise.getProgressionMethods().count) *
                ExerciseChartViewWithToggles.heightPerProgressionMethodButton +
                PrettySegmentedControl.defaultHeight + Chart.defaultHeight
    }
    
    // Creates a chart with the given selected information
    public func createChart() {
        // Remove any view from chart frame so we don't draw over and over
        chartFrame.removeAllSubviews()
        
        let frame = CGRect(x: 0,
                           y: 0,
                           width: chartWidth,
                           height: Chart.defaultHeight)
        
        // Create chart returns (chart, bool) representing the chart, and if the graph is viewable to the user.
        let chartInfo = createChartFromExerciseHistory(exerciseHistory: exercise.getExerciseHistory(),
                                                       filterProgressionMethods: filterProgressionMethods,
                                                       timeAmount: selectedTimeAmount,
                                                       frame: frame)
        // If the graph is viewable to the user, work it!
        if chartInfo.1 {
            chart = chartInfo.0
            chart!.view.backgroundColor = .primaryBlackWhiteColor
            chartFrame.addSubview(chart!.view)
        } else {
            let cannotGraphView = UILabel(frame: frame)
            cannotGraphView.backgroundColor = .lightBlackWhiteColor
            cannotGraphView.textColor = .niceBlue
            cannotGraphView.textAlignment = .center
            // 8 is chosen arbitrarily.
            cannotGraphView.numberOfLines = 8
            cannotGraphView.text = "Not enough information to graph.\n" +
                                    "Please complete this exercise on multiple different days to track your progress."
            
            chartFrame.addSubview(cannotGraphView)
        }
        
        layoutSubviews()
    }
    
    // Destroys the chart being shown in memory. Used for saving memory
    public func destroyChart() {
        if chart != nil {
            chart?.view.removeFromSuperview()
            chart = nil
            chartFrame.removeAllSubviews()
            layoutSubviews()
        }
    }
    
    // MARK: Event functions
    
    // Whenever a toggle button is pressed, activate or deactivate them from the graph
    @objc private func toggleButtonPress(sender: ToggleablePrettyButtonWithProgressionMethod) {
        if sender.isToggled {
            filterProgressionMethods.remove(sender.progressionMethod)
        } else {
            filterProgressionMethods.insert(sender.progressionMethod)
        }
        
        createChart()
    }
    
    // MARK: PrettySegmentedControlDelegate functions
    
    func segmentSelectionChanged(index: Int) {
        selectedTimeAmount = TimeAmountArray[index]
        
        createChart()
    }
    
    // MARK: Constraint Functions
    
    // Center horiz in view ; below cellTitle ; width of this view * 0.85 ; height of default
    private func createAndActivateTimeAmountSelectionViewConstraints() {
        timeAmountSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: timeAmountSelectionView,
                                                         height: PrettySegmentedControl.defaultHeight).isActive = true
    }
    
    // Center horiz in view ; Width of this view ; Below cell title ; Height of Chart's default height
    private func createAndActivateChartFrameConstraints() {
        chartFrame.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: chartFrame,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: chartFrame,
                                                             withCopyView: timeAmountSelectionView,
                                                             attribute: .width).isActive = true
        NSLayoutConstraint.createViewBelowViewConstraint(view: chartFrame,
                                                         belowView: timeAmountSelectionView,
                                                         withPadding: 0).isActive = true
        NSLayoutConstraint.createHeightConstraintForView(view: chartFrame,
                                                         height: Chart.defaultHeight).isActive = true
    }
    
    //  Creates the buttons and lines them up in a downwards fashion.
    private func createProgressionMethodFilterButtons() {
        // The last view before these (in terms of top to bottom)
        var prevView: UIView = chartFrame
        
        for progressionMethod in exercise.getProgressionMethods() {
            let progressionMethodButton = ToggleablePrettyButtonWithProgressionMethod(
                progressionMethod: progressionMethod,
                frame: .zero)
            progressionMethodButton.setTitle(progressionMethod.getName(), for: .normal)
            progressionMethodButton.setIsToggled(toggled: true)
            progressionMethodButton.setToggleTextColor(color: .white)
            progressionMethodButton.setDefaultTextColor(color: .white)
            progressionMethodButton.setToggleViewColor(color:
                getColorsForIndex(progressionMethod.getIndex()!)[0])
            progressionMethodButton.setDefaultViewColor(color: .lightBlackWhiteColor)
            progressionMethodButton.addTarget(self,
                                              action: #selector(toggleButtonPress(sender:)),
                                              for: .touchUpInside)
            addSubview(progressionMethodButton)
            
            // Constraints for this exercise label.
            // Place 10 from left/right of the cell
            // Place 10 below above view, height of 20
            
            progressionMethodButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodButton,
                                                                 withCopyView: self,
                                                                 attribute: .centerX).isActive = true
            NSLayoutConstraint.createViewBelowViewConstraint(view: progressionMethodButton,
                                                             belowView: prevView,
                                                             withPadding: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodButton,
                                                                 withCopyView: chartFrame,
                                                                 attribute: .width).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(
                view: progressionMethodButton,
                height: ExerciseChartViewWithToggles.heightPerProgressionMethodButton).isActive = true
            
            progressionButtons.append(progressionMethodButton)
            
            prevView = progressionMethodButton
        }
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
