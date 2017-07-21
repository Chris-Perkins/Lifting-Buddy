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
        
        let todayString = /*NSDate().dayOfTheWeek()*/ "TEST"
        if realm.objects(Workout.self).filter(
                NSPredicate(format: "dayOfTheWeek = %@", todayString)).count == 1 {
        } else {
            try! realm.write {
                let workout: Workout = realm.create(Workout.self)
                workout.setDayOfTheWeek(day: todayString)
                workout.setName(name: "[WORKOUT NAME TEST]")
            }
        }
        
        print(realm.objects(Workout.self))
    }
    
    // We have workouts to display
    func addWorkoutsDisplay(workout: Workout) {
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
