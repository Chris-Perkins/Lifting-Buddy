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
    
    private var workoutView: WorkoutsView? = nil
    private var exercisesView: ExercisesView? = nil
    private var aboutView: AboutView? = nil
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .niceGray
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: View functions
    
    func showContentView(viewType: SectionView.ContentViews) {
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: sectionContentView.frame.size.width,
                                   height: sectionContentView.frame.size.height)
        
        switch(viewType) {
        case SectionView.ContentViews.WORKOUTS:
            if workoutView == nil {
                workoutView = WorkoutsView(frame: frame)
            }
            sectionContentView.addSubview(workoutView!)
        case SectionView.ContentViews.EXERCISES:
            if exercisesView == nil {
                exercisesView = ExercisesView(frame: frame)
            }
            sectionContentView.addSubview(exercisesView!)
        case SectionView.ContentViews.ABOUT:
            if aboutView == nil {
                aboutView = AboutView(frame: frame)
            }
            sectionContentView.addSubview(aboutView!)
        }
    }
}
