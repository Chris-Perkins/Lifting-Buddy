//
//  ExerciseGraphView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/5/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import SwiftCharts
import RealmSwift

func createChartFromExerciseHistory(exerciseHistory: List<ExerciseHistoryEntry>,
                                    filterProgressionMethods: Set<ProgressionMethod> = Set<ProgressionMethod>(),
                                    timeAmount: TimeAmount,
                                    frame: CGRect) -> (Chart, Bool) {
    
    let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 18),
                                           fontColor: .niceBlue)
    
    let chartFrame = CGRect(x: 0,
                            y: 0,
                            width: frame.width,
                            height: frame.height)
    let chartSettings = ChartSettings.getDefaultSettings()
    
    let displayFormatter = NSDate.getDateFormatter()
    
    // the lines we're drawing
    var lineModels = [ChartLineModel]()
    // the points associated per progression method (for drawing lines)
    var pointDictionary = Dictionary<ProgressionMethod, [ChartPoint]>()
    
    // the minimum date we've encountered (used in displaying all-time)
    var minimumDate = Date.init(timeIntervalSinceNow: 0)
    var maximumDate = Date.init(timeIntervalSince1970: 0)
    
    // Used in determining the y-axis maximum and minimums for graphing
    var maxDataValue: Float = 0
    var minDataValue: Float = 0
    
    // If we have multiple of the same chart, we can graph.
    // If we don't, we can't graph (lines require 2 points)
    var containsLine = false
    
    // This for loop gets all points for all progressionmethods in the history
    for exerciseHistoryEntry in exerciseHistory {
        // Update the minimum date
        minimumDate = min(minimumDate, exerciseHistoryEntry.date!)
        maximumDate = max(maximumDate, exerciseHistoryEntry.date!)
        
        // Gets the max per progression method to be displayed
        for exercisePiece in exerciseHistoryEntry.exerciseInfo {
            if !filterProgressionMethods.contains(exercisePiece.progressionMethod!) {
                guard let progressionMethod = exercisePiece.progressionMethod else {
                    fatalError("Progression method nil while creating graph")
                }
                
                let chartPoint = createChartPoint(date: exerciseHistoryEntry.date!,
                                                  value: exercisePiece.value!.floatValue!,
                                                  displayFormatter: displayFormatter)
                
                // If the key is in the dictionary, append it!
                // This also means a line exists (point already appended before)
                if let _ = pointDictionary[progressionMethod] {
                    pointDictionary[progressionMethod]!.append(chartPoint)
                    containsLine = true
                } else {
                    pointDictionary[progressionMethod] = [chartPoint]
                }
                
                maxDataValue = max(maxDataValue, exercisePiece.value!.floatValue!)
                minDataValue = min(minDataValue, exercisePiece.value!.floatValue!)
            }
        }
    }

    // Now create line models for every progression method
    for (progressionMethod, points) in pointDictionary {
        guard let index: Int = progressionMethod.getIndex() else {
            fatalError("Proper index not assigned! Index int returned nil.")
        }
        
        lineModels.append(ChartLineModel(chartPoints: points,
                                         lineColors: getColorsForIndex(index),
                                         lineWidth: 3,
                                         animDuration: 0,
                                         animDelay: 0))
    }
    
    // If we went **higher** than zero for our min value, set this back to zero.
    // Makes graphs less confusing.
    minDataValue = minDataValue > 0 ? 0 : minDataValue
    
    var yValues = [ChartAxisValueDouble]()
    var prevValue: Int? = nil
    let increaseByValue = Int(maxDataValue + 5 - minDataValue) / 5
    for index in 0...5 {
        let newValue = Int(minDataValue) + increaseByValue * index
        
        // We always want to display 0 on our graph for clarity reasons.
        if prevValue != nil && prevValue! < 0 && newValue > 0 {
            yValues.append(ChartAxisValueDouble(0.0, labelSettings: labelSettings))
        }
        yValues.append(ChartAxisValueDouble(newValue, labelSettings: labelSettings))
        
        prevValue = newValue
    }
    
    var xValues = [ChartAxisValue]()
    
    switch (timeAmount) {
    case TimeAmount.MONTH:
        for i in -5...0 {
            xValues.append(createDateAxisValue(Calendar.current.date(byAdding: .day,
                                                                     value: 6 * i,
                                                                     to: Date(timeIntervalSinceNow: 0))!,
                                               displayFormatter: displayFormatter))
        }
    break
    case TimeAmount.YEAR:
        for i in -6...0 {
            xValues.append(createDateAxisValue(Calendar.current.date(byAdding: .month,
                                                                     value: i * 2,
                                                                     to: Date(timeIntervalSinceNow: 0))!,
                                               displayFormatter: displayFormatter))
        }
    break
    case TimeAmount.ALLTIME:
        let distanceBetweenMinAndToday = Date.init(timeIntervalSinceNow: 0).timeIntervalSince(minimumDate)
        
        var prevDate: Date? = nil
        for i in -6...0 {
            let date = Date.init(timeIntervalSinceNow: Double(i) / 6.0 * distanceBetweenMinAndToday)
            
            // Don't show duplicate labels
            if prevDate != nil && (Calendar.current.isDate(date, inSameDayAs: prevDate!)) {
                xValues.remove(at: xValues.count - 1)
            }
                
            xValues.append(
                    createDateAxisValue(Date.init(timeIntervalSinceNow: Double(i) / 6.0 * distanceBetweenMinAndToday),
                                                displayFormatter: displayFormatter))
            prevDate = date
        }
    }
    
    let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings))
    let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "", settings: labelSettings))
    
    let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
    let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

    let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: lineModels) // || CubicLinePathGenerator
    
    let settings = ChartGuideLinesDottedLayerSettings(linesColor: .niceLightBlue,
                                                      linesWidth: 1)
    let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer,
                                                     yAxisLayer: yAxisLayer,
                                                     settings: settings)
    
    return (Chart(
                frame: chartFrame,
                innerFrame: innerFrame,
                settings: chartSettings,
                layers: [
                    xAxisLayer,
                    yAxisLayer,
                    guidelinesLayer,
                    chartPointsLineLayer
                ]
            ),
            // If we did a workout at least twenty-four hours afterward, we can view distance on the graph.
            // Also, make sure there is a valid line to graph. Otherwise... Why graph?
            (maximumDate.seconds(from: minimumDate) >= 24 * 60 * 60) && containsLine
        )
}

private func createChartPoint(date: Date, value: Float, displayFormatter: DateFormatter) -> ChartPoint {
    return ChartPoint(x: createDateAxisValue(date,
                                             displayFormatter: displayFormatter),
                      y: ChartAxisValueDouble(Double(value)))
}

private func createDateAxisValue(_ date: Date, displayFormatter: DateFormatter) -> ChartAxisValue {
    let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 18),
                                           fontColor: .niceBlue,
                                           rotation: 90,
                                           rotationKeep: .top)
    return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
}
