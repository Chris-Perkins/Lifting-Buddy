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
    
    private var homeView: UIView? = nil
    private var workoutView: UIView? = nil
    private var exercisesView: UIView? = nil
    private var settingsView: UIView? = nil
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.niceGray()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: View functions
    
    func showContentView(viewType: SectionView.ContentViews) {
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: self.sectionContentView.frame.size.width,
                                   height: self.sectionContentView.frame.size.height)
        
        switch(viewType) {
        case SectionView.ContentViews.WORKOUTS:
            if self.workoutView == nil {
                self.workoutView = WorkoutsView(frame: frame)
            }
            self.sectionContentView.addSubview(workoutView!)
        case SectionView.ContentViews.EXERCISES:
            if self.exercisesView == nil {
                self.exercisesView = ExercisesView(frame: frame)
            }
            self.sectionContentView.addSubview(exercisesView!)
        case SectionView.ContentViews.SETTINGS:
            if self.settingsView == nil {
                self.settingsView = SettingsView(frame: frame)
            }
            
            self.sectionContentView.addSubview(settingsView!)
        }
    }
}
