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
    
    for (_, value) in pointDictionary {
        lineModels.append(ChartLineModel(chartPoints: value,
                                         lineColor: UIColor.niceYellow(),
                                         lineWidth: 3,
                                         animDuration: 1,
                                         animDelay: 0))
    }
    
    let yValues = stride(from: 0, through: 200, by: 20).map {ChartAxisValueDouble($0, labelSettings: labelSettings)}
    
    var xValues = [ChartAxisValue]()
    
    switch (timeAmount) {
    case TimeAmount.MONTH:
        for i in -10...0 {
            xValues.append(createDateAxisValue(Calendar.current.date(byAdding: .day,
                                                                     value: 3 * i,
                                                                     to: Date(timeIntervalSinceNow: 0))!,
                                               displayFormatter: displayFormatter))
        }
    break
    case TimeAmount.YEAR:
        for i in -12...0 {
            xValues.append(createDateAxisValue(Calendar.current.date(byAdding: .month,
                                                                     value: i,
                                                                     to: Date(timeIntervalSinceNow: 0))!,
                                               displayFormatter: displayFormatter))
        }
    break
    case TimeAmount.ALLTIME:
        let distanceBetweenMinAndToday = Date.init(timeIntervalSinceNow: 0).timeIntervalSince(minimumDate)
        
        for i in -10...0 {
            xValues.append(
                createDateAxisValue(Date.init(timeIntervalSinceNow: Double(i)/10.0 * distanceBetweenMinAndToday),
                                               displayFormatter: displayFormatter))
        }
    default:
        fatalError("GRAPH FOR IMPLEMENTED TIMEAMOUNT NOT YET IMPLEMENTED")
    }
    
    let xModel = ChartAxisModel(axisValues: xValues, axisTitleLabel: ChartAxisLabel(text: "Date", settings: labelSettings))
    let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Value", settings: labelSettings.defaultVertical()))
    
    let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
    let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
    
    //let lineModel = ChartLineModel(chartPoints: chartPoints, lineColor: UIColor.niceYellow(), lineWidth: 3, animDuration: 1, animDelay: 0)
    /*let lineModel2 = ChartLineModel(chartPoints: [
        createChartPoint(dateStr: "24-12-2014", percent: 23, readFormatter: readFormatter, displayFormatter: displayFormatter),
        createChartPoint(dateStr: "04-06-2015", percent: 51, readFormatter: readFormatter, displayFormatter: displayFormatter)], lineColor: UIColor.niceRed(), lineWidth: 3, animDuration: 1, animDelay: 0)*/
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

public func getLineColorForIndex(index: Int) {
    
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
