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
    
    func showContentView(viewType: SectionView.contentViews) {
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: self.sectionContentView.frame.size.width,
                                   height: self.sectionContentView.frame.size.height)
        
        switch(viewType) {
        case SectionView.contentViews.SETTINGS:
            self.sectionContentView.addSubview(SettingsView(frame: frame))
            break
        default:
            break
        }
    }
}
