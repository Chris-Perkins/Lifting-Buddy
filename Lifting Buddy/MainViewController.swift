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
        
        self.view.backgroundColor = UIColor.niceGray()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: View functions
    
    // We have workouts to display
    func addWorkoutsDisplay(workout: Workout) {
    }
    
    func showContentView(viewType: SectionView.ContentViews) {
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: self.sectionContentView.frame.size.width,
                                   height: self.sectionContentView.frame.size.height)
        
        switch(viewType) {
        case SectionView.ContentViews.WORKOUTS:
            self.sectionContentView.addSubview(WorkoutsView(frame: frame))
            break
        case SectionView.ContentViews.SETTINGS:
            self.sectionContentView.addSubview(SettingsView(frame: frame))
            break
        default:
            break
        }
    }
}
