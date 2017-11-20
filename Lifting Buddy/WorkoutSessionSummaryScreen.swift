//
//  WorkoutSessionSummaryScreen.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 11/19/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class WorkoutSessionSummaryScreen: UIView {
    init(withExercises: List<Exercise>) {
        super.init(frame: .zero)
        
        self.backgroundColor = UIColor.niceBlue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
