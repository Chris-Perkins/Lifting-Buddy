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
    let exercise: Exercise
    
    // the time amount we're currently displaying
    private var selectedTimeAmount: TimeAmount
    // Filter progressionMethods from graph
    private var filterProgressionMethods: Set<ProgressionMethod>
    // the chart we're showing
    private var chart: Chart?
    // the amount of space the chart can take up width-wise
    private var chartWidth: CGFloat
    
    // A view we use to select a date view
    private var timeAmountSelectionView: PrettySegmentedControl
    // The view where we'll put the chart
    private var chartFrame: UIView
    // The labels for every exercise
    private var progressionButtons: [ToggleablePrettyButtonWithProgressionMethod]
    
    // MARK: Inits
    init(exercise: Exercise, chartWidth: CGFloat) {
        self.exercise = exercise
        self.selectedTimeAmount = TimeAmount.ALLTIME
        self.filterProgressionMethods = Set<ProgressionMethod>()
        self.chartWidth = chartWidth
        
        self.timeAmountSelectionView = PrettySegmentedControl(labelStrings: TimeAmountArray.map {$0.rawValue},
                                                              frame: .zero)
        self.chartFrame = UIView()
        self.progressionButtons = [ToggleablePrettyButtonWithProgressionMethod]()
        
        super.init(frame: .zero)
        
        self.timeAmountSelectionView.delegate = self
        
        self.addSubview(self.timeAmountSelectionView)
        self.addSubview(self.chartFrame)
        
        self.createAndActivateTimeAmountSelectionViewConstraints()
        self.createAndActivateChartFrameConstraints()
        self.createProgressionMethodFilterButtons()
        
        self.createChart()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View overrides
    
    override public func layoutIfNeeded() {
        super.layoutIfNeeded()
        self.backgroundColor = UIColor.niceRed
        
        self.chartFrame.clipsToBounds = true
        
        self.filterProgressionMethods.removeAll()
        
        self.chartFrame.backgroundColor = UIColor.niceRed
    }
    
    // MARK: Custom view functions
    
    static func getNecessaryHeightForExerciseGraph(exercise: Exercise) -> CGFloat {
        return CGFloat(exercise.getProgressionMethods().count) *
            ExerciseChartViewWithToggles.heightPerProgressionMethodButton +
            PrettySegmentedControl.defaultHeight + Chart.defaultHeight
    }
    
    // Creates a chart with the given selected information
    private func createChart() {
        self.chart?.view.removeFromSuperview()
        
        self.chart = createChartFromExerciseHistory(exerciseHistory: self.exercise.getExerciseHistory(),
                                                    filterProgressionMethods: self.filterProgressionMethods,
                                                    timeAmount: self.selectedTimeAmount,
                                                    frame: CGRect(x: 0,
                                                                  y: 0,
                                                                  width: chartWidth,
                                                                  height: Chart.defaultHeight))
        chart!.view.backgroundColor = UIColor.white
        self.chartFrame.addSubview(chart!.view)
        
        self.layoutSubviews()
    }
    
    // MARK: Event functions
    
    // Whenever a toggle button is pressed, activate or deactivate them from the graph
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
    
    // MARK: Constraint Functions
    
    // Center horiz in view ; below cellTitle ; width of this view * 0.85 ; height of default
    private func createAndActivateTimeAmountSelectionViewConstraints() {
        self.timeAmountSelectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .centerX).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .top).isActive = true
        NSLayoutConstraint.createViewAttributeCopyConstraint(view: self.timeAmountSelectionView,
                                                             withCopyView: self,
                                                             attribute: .width).isActive = true
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
                                                         height: Chart.defaultHeight).isActive = true
    }
    
    //  Creates the buttons and lines them up in a downwards fashion.
    private func createProgressionMethodFilterButtons() {
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
                                                             withPadding: 0).isActive = true
            NSLayoutConstraint.createViewAttributeCopyConstraint(view: progressionMethodButton,
                                                                 withCopyView: self.chartFrame,
                                                                 attribute: .width).isActive = true
            NSLayoutConstraint.createHeightConstraintForView(
                view: progressionMethodButton,
                height: ExerciseChartViewWithToggles.heightPerProgressionMethodButton).isActive = true
            
            self.progressionButtons.append(progressionMethodButton)
            
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
