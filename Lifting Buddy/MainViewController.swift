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
    // MARK: IBOutlets
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var sectionContentView: UIView!
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Attempt to access local storage
        let realm = try! Realm()
        
        let todayString = "TEST"
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: View functions
    
    // We have workouts to display
    func addWorkoutsDisplay(workout: Workout) {
    }
    
    @objc func showSettingsView() {
        removeSectionContentSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: self.sectionContentView.frame.size.width,
                                   height: self.sectionContentView.frame.size.height)
        self.sectionContentView.addSubview(SettingsView(frame: frame))
    }
    
    // Remove all views from the superview
    func removeSectionContentSubviews() {
        for subview in self.sectionContentView.subviews {
            subview.removeFromSuperview()
        }
    }
}

// MARK: Extensions


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
