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
    
    private var sessionView: WorkoutSessionView? = nil
    private var workoutView: WorkoutsView? = nil
    private var exercisesView: ExercisesView? = nil
    private var aboutView: AboutView? = nil
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .niceGray
        
        let _ = view
    }
    
    // MARK: View functions
    
    func showContentView(viewType: SectionView.ContentViews) {
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: sectionContentView.frame.size.width,
                                   height: sectionContentView.frame.size.height)
        
        switch(viewType) {
        case SectionView.ContentViews.SESSION:
            guard let sessionView = sessionView else {
                fatalError("Session view called, but is nil!")
            }
            sectionContentView.addSubview(sessionView)
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
            showView(aboutView!)
        }
    }
}

extension MainViewController: WorkoutSessionStarter {
    func startSession(workout: Workout?,
                      exercise: Exercise?) {
        if sessionView == nil {
            self.showSession(workout: workout,
                             exercise: exercise)
        } else {
            let alert = UIAlertController(title: "Quit current workout session?",
                                          message: "To start a new session, you must end your current session. All data from the active session will not be saved. Continue?",
                                          preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "Cancel",
                                             style: .cancel,
                                             handler: nil)
            let continueButton = UIAlertAction(title: "Continue",
                                               style: .destructive,
                                               handler: { UIAlertAction -> Void in
                    self.showSession(workout: workout,
                                    exercise: exercise)
                })
            alert.addAction(cancelButton)
            alert.addAction(continueButton)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func showSession(workout: Workout?,
                             exercise: Exercise?) {
        
        sectionContentView.removeAllSubviews()
        
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: sectionContentView.frame.size.width,
                                   height: sectionContentView.frame.size.height)
        
        sessionView = WorkoutSessionView(workout: workout,
                                         frame: frame)
        sessionView!.showViewDelegate = self
        sessionView?.workoutSessionDelegate = self
        
        if let appendedExercise = exercise {
            sessionView!.workoutSessionTableView.appendDataToTableView(data: appendedExercise)
        }
        
        headerView.sectionView.createSessionButton()
        showView(sessionView!)
    }
    
    // On workout end, navigate back to the workout view.
    func endSession() {
        showContentView(viewType: SectionView.ContentViews.WORKOUTS)
        sessionView = nil
        headerView.sectionView.removeSessionButton()
    }
}

extension MainViewController: ShowViewDelegate {
    func showView(_ view: UIView) {
        let frame: CGRect = CGRect(x: 0,
                                   y: 0,
                                   width: sectionContentView.frame.size.width,
                                   height: sectionContentView.frame.size.height)
        view.frame = frame
        
        sectionContentView.addSubview(view)
    }
}

@objc protocol WorkoutSessionStarter {
    /*
     * Notified when a workout is starting
     */
    func startSession(workout: Workout?,
                      exercise: Exercise?)
    /*
     * Notified when a workout is ending
     */
    @objc optional func endSession()
}
