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
    }
    
    // MARK: View functions
    
    func showContentView(viewType: SectionView.ContentViews) {
        sectionContentView.removeAllSubviews()
        
        switch(viewType) {
        case SectionView.ContentViews.SESSION:
            guard let sessionView = sessionView else {
                fatalError("Session view called, but is nil!")
            }
            showView(sessionView)
            
        case SectionView.ContentViews.WORKOUTS:
            if workoutView == nil {
                workoutView = WorkoutsView(frame: .zero)
            }
            showView(workoutView!)
            
        case SectionView.ContentViews.EXERCISES:
            if exercisesView == nil {
                exercisesView = ExercisesView(frame: .zero)
            }
            showView(exercisesView!)
            
        case SectionView.ContentViews.ABOUT:
            if aboutView == nil {
                aboutView = AboutView(frame: .zero)
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
                                          message: "To start a new session, you must end your current session. All data from the active workout session will not be saved. Continue?",
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
        AppDelegate.sessionWorkout = workout
        if workout != nil {
            for exercise in workout!.getExercises() {
                AppDelegate.sessionExercises.insert(exercise)
            }
        }
        if exercise != nil {
            AppDelegate.sessionExercises.insert(exercise!)
        }
        
        sessionView = WorkoutSessionView(workout: workout,
                                         frame: .zero)
        
        sessionView!.showViewDelegate = self
        sessionView?.workoutSessionDelegate = self
        
        if let appendedExercise = exercise {
            sessionView!.workoutSessionTableView.appendDataToTableView(data: appendedExercise)
        }
        
        headerView.sectionView.showSessionButton()
        showView(sessionView!)
    }
    
    // On workout end, navigate back to the workout view.
    func endSession() {
        AppDelegate.sessionWorkout = nil
        AppDelegate.sessionExercises.removeAll()
        
        showContentView(viewType: SectionView.ContentViews.WORKOUTS)
        sessionView = nil
        headerView.sectionView.hideSessionButton()
    }
}

extension MainViewController: ShowViewDelegate {
    func showView(_ view: UIView) {
        sectionContentView.addSubview(view)
        
        NSLayoutConstraint.clingViewToView(view: view,
                                           toView: sectionContentView)
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
