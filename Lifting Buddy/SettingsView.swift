//
//  SettingsView.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/5/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import SwiftCharts
import Realm
import RealmSwift

class SettingsView: UIView {
    
    var chart: Chart?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let realm = try! Realm()
        let chart = createChartFromExercise(exercise: realm.objects(Exercise.self).first!, frame: frame)
        self.chart = chart
        self.addSubview(chart.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
