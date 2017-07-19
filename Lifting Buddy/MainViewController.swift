//
//  ViewController.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class MainViewController: UIViewController {
    @IBOutlet weak var dayOfTheWeekLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var quickStartView: UIView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Attempt to access local storage
        let realm = try! Realm()
        
        // Adding views
        /* !-- HEADER VIEW SECTION --! */
        // Header view layout
        headerView.layer.shadowColor = UIColor.black.cgColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0)
        headerView.layer.shadowRadius = 3.0
        headerView.layer.shadowOpacity = 0.4
        
        // Day of the week label marks
        dayOfTheWeekLabel.numberOfLines = 1
        dayOfTheWeekLabel.text = NSDate().dayOfTheWeek()!
        dayOfTheWeekLabel.adjustsFontSizeToFitWidth = true
        
        let todayString = NSDate().dayOfTheWeek()
        if let workoutToday: Workout = realm.objects(Workout.self).filter(
                NSPredicate(format: "dayOfTheWeek = %@", todayString!)).first {
            addWorkoutDisplay(workout: workoutToday)
        } else {
            try! realm.write() {
                let workout: Workout = realm.create(Workout.self, value:["Tuesday"])
                workout.setDayOfTheWeek(day: "Tuesday")
            }
            
            print(realm.objects(Workout.self))
        }
    }
    
    func addWorkoutDisplay(workout: Workout) {
        /* !-- QUICK START LAYOUT --! */
        var quickStartSubviews: [UIView] = [UIView]()
        
        // Start today's workout button
        let startTodayWorkoutButton: PrettyButton =
            PrettyButton(frame: CGRect(x: 0, y: 0,
                                       width: quickStartView.frame.width,
                                       height: 100))
        startTodayWorkoutButton.setTitle("Start Today's Workout", for: .normal)
        startTodayWorkoutButton.cornerRadius = 5.0
        startTodayWorkoutButton.shadowOpacity = 0.2
        startTodayWorkoutButton.setTitleColor(UIColor.white, for: .normal)
        startTodayWorkoutButton.backgroundColor = headerView.backgroundColor
        
        quickStartSubviews.append(startTodayWorkoutButton)
        
        // Start other workout button
        let startOtherWorkoutButton: PrettyButton =
            PrettyButton(frame: CGRect(x: 25, y: 0,
                                       width: quickStartView.frame.width - 50,
                                       height: 75))
        startOtherWorkoutButton.setTitle("Start Different Workout", for: .normal)
        startOtherWorkoutButton.setTitleColor(UIColor(red: 0, green: 122.0 / 255.0,
                                                      blue: 1.0, alpha: 1), for: .normal)
        startOtherWorkoutButton.cornerRadius = 5.0
        startOtherWorkoutButton.shadowOpacity = 0.2
        startOtherWorkoutButton.backgroundColor = UIColor.white
        startOtherWorkoutButton.slideColor = UIColor(white: 0.7, alpha: 1)
        
        quickStartSubviews.append(startOtherWorkoutButton)
        
        addSubviewsToViewWithYPadding(mainView: quickStartView, subviews: quickStartSubviews, spacing: 50)
    }
}

extension NSDate {
    // Get the current day of the week (in string format) ex: "Monday"
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self as Date)
    }
}

extension Results {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}

extension RealmSwift.List {
    
    func toArray() -> [T] {
        return self.map{$0}
    }
}
