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

public enum TimeAmount {
    case WEEK
    case MONTH
    case YEAR
    case ALLTIME
}

func createChartFromExerciseHistory(exerciseHistory: List<ExerciseHistoryEntry>,
                                    filterProgressionMethods: Set<ProgressionMethod> = Set<ProgressionMethod>(),
                                    timeAmount: TimeAmount,
                                    frame: CGRect) -> Chart {
    
    let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 18), fontColor: UIColor.niceBlue())
    
    let chartFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    let chartSettings = ChartSettings.getDefaultSettings()
    
    let displayFormatter = NSDate.getDateFormatter()
    
    // the lines we're drawing
    var lineModels = [ChartLineModel]()
    // the points associated per progression method (for drawing lines)
    var pointDictionary = Dictionary<ProgressionMethod, [ChartPoint]>()
    
    // the minimum date we've encountered (used in displaying all-time)
    var minimumDate = Date.init(timeIntervalSinceNow: 0)
    var maxDataValue: Float = 0
    var minDataValue: Float = 0
    
    
    for exerciseHistoryEntry in exerciseHistory {
        // Update the minimum date
        minimumDate = min(minimumDate, exerciseHistoryEntry.date!)
        
        // Gets the max per progression method to be displayed
        var maxPerProgressionMethod = Dictionary<ProgressionMethod, Float>()
        for exercisePiece in exerciseHistoryEntry.exerciseInfo {
            if !filterProgressionMethods.contains(exercisePiece.progressionMethod!) {
                if let val = maxPerProgressionMethod[exercisePiece.progressionMethod!] {
                    maxPerProgressionMethod[exercisePiece.progressionMethod!] = max(val, exercisePiece.value!.floatValue!)
                } else {
                    maxPerProgressionMethod[exercisePiece.progressionMethod!] = exercisePiece.value!.floatValue!
                }
                
                maxDataValue = max(maxDataValue, exercisePiece.value!.floatValue!)
                minDataValue = min(minDataValue, exercisePiece.value!.floatValue!)
            }
        }
        
        for key in maxPerProgressionMethod.keys {
            let chartPoint = createChartPoint(date: exerciseHistoryEntry.date!,
                                              value: maxPerProgressionMethod[key]!,
                                              displayFormatter: displayFormatter)
            
            if var _ = pointDictionary[key] {
                pointDictionary[key]!.append(chartPoint)
            } else {
                pointDictionary[key] = [chartPoint]
            }
        }
    }
    
    for (key, value) in pointDictionary {
        lineModels.append(ChartLineModel(chartPoints: value,
                                         lineColors: getLineColorsForProgressionMethod(progressionMethod: key),
                                         lineWidth: 3,
                                         animDuration: 0,
                                         animDelay: 0))
    }
    
    // If we went **higher** than zero for our min value, set this back to zero.
    // Makes graphs less confusing.
    minDataValue = minDataValue > 0 ? 0 : minDataValue
    
    let yValues = stride(from: Int(minDataValue),
                         through: Int(maxDataValue) + 5,
                         by: Int(maxDataValue + 5 - minDataValue) / 5).map {
                            ChartAxisValueDouble($0, labelSettings: labelSettings) }
    
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
    default:
        fatalError("GRAPH FOR TIMEAMOUNT TYPE NOT YET IMPLEMENTED")
    }
    
    let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
    let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Value", settings: labelSettings.defaultVertical()))
    
    let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
    let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)

    let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: lineModels) // || CubicLinePathGenerator
    
    let settings = ChartGuideLinesDottedLayerSettings(linesColor: UIColor.niceLightBlue(), linesWidth: 1)
    let guidelinesLayer = ChartGuideLinesDottedLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: settings)
    
    return Chart(
        frame: chartFrame,
        innerFrame: innerFrame,
        settings: chartSettings,
        layers: [
            xAxisLayer,
            yAxisLayer,
            guidelinesLayer,
            chartPointsLineLayer
        ]
    )
}

func getLineColorsForProgressionMethod(progressionMethod: ProgressionMethod) -> [UIColor] {
    var colors = [UIColor]()
    let modCount = 10
    
    guard var index: Int = progressionMethod.getIndex() else {
        fatalError("Proper index not assigned! Index int returned nil.")
    }
    
    // + 1 so index starting at 0 is given a color
    index += 1
    var i = 0
    var previousColor = -1
    while index > 0 {
        var color: UIColor?
        var colorIndex = mod(x: index, m: modCount)
        if colorIndex == previousColor {
            colorIndex = mod(x: colorIndex + 1, m: modCount)
        }
        
        switch (colorIndex) {
        case 0:
            color = UIColor.niceRed()
        case 1:
            color = UIColor.niceBlue()
        case 2:
            color = UIColor.niceGreen()
        case 3:
            color = UIColor.niceYellow()
        case 4:
            color = UIColor.niceCyan()
        case 5:
            color = UIColor.niceBrown()
        case 6:
            color = UIColor.nicePurple()
        case 7:
            color = UIColor.niceMediterranean()
        case 8:
            color = UIColor.niceMaroon()
        case 9:
            color = UIColor.niceOrange()
        default:
            fatalError("Modulo returned OOB value. Check case amount in ExerciseChartCreator -> GetLineColor Method")
        }
        
        i += 1
        // Up this based on mod count. Should be the ceil of closest 10 to modCount
        // Ex: modCount 9 -> 10, modCount 11 -> 100
        index = index / 10^^i
        previousColor = colorIndex
        colors.append(color!)
    }
    return colors
}

private func mod(x: Int, m: Int) -> Int {
    let r = x % m
    return r < 0 ? r + m : r
}

private func createChartPoint(date: Date, value: Float, displayFormatter: DateFormatter) -> ChartPoint {
    return ChartPoint(x: createDateAxisValue(date,
                                             displayFormatter: displayFormatter),
                      y: ChartAxisValueDouble(Double(value)))
}

private func createDateAxisValue(_ date: Date, displayFormatter: DateFormatter) -> ChartAxisValue {
    let labelSettings = ChartLabelSettings(font: UIFont.systemFont(ofSize: 18),
                                           fontColor: UIColor.niceBlue(),
                                           rotation: 90,
                                           rotationKeep: .top)
    return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
}
