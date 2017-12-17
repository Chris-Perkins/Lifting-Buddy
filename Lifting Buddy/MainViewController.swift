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
import CDAlertView
import GBVersionTracking

class MainViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var sectionContentView: UIView!
    
    // MARK: View properties
    
    // Cache the views so data is stored between user navigation.
    
    // The session view is special since it's main view can change.
    // Possibilities are workoutsession or summaryscreen.
    private var sessionView: UIView? = nil
    private var workoutView: WorkoutsView? = nil
    private var exercisesView: ExercisesView? = nil
    private var aboutView: AboutView? = nil
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .niceGray
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "aboutSegue" {
            let popoverViewController = segue.destination
            popoverViewController.modalPresentationStyle = .popover
            popoverViewController.popoverPresentationController!.delegate = self
        }
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
            exercisesView?.layoutSubviews()
            
        /*case SectionView.ContentViews.ABOUT:
            /*if aboutView == nil {
                aboutView = AboutView(frame: .zero)
            }
            showView(aboutView!)*/
            let alert = CDAlertView(title: "Lifting Buddy " +
                                        "v\(GBVersionTracking.currentVersion()!)",
                                    message: "Your free, open-source workout tracking application.\n\n" +
                                        "Email Support:\nchris@chrisperkins.me",
                                    type: CDAlertViewType.custom(image: #imageLiteral(resourceName: "LiftingBuddyImage")))
            alert.add(action: CDAlertViewAction(title: "Close",
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue,
                                                handler: nil))
            alert.show()*/
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
            let alert = CDAlertView(title: "Quit Current Workout Session?",
                                    message: "To start a new session, you must end your current session.\n" +
                                        "You will not gain streak progress.",
                                    type: CDAlertViewType.warning)
            alert.add(action: CDAlertViewAction(title: "Cancel",
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue, handler: nil))
            alert.add(action: CDAlertViewAction(title: "Quit",
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceRed,
                                                handler: { (CDAlertViewAction) in
                                                    /*
                                                        Note: The below lines are done to
                                                        free the AppDelegate lock
                                                        on workouts whose sessions
                                                        have not ended.
                                                    */
                                                    (self.sessionView as? WorkoutSessionView)?.endSession()
                                                    (self.sessionView as? WorkoutSessionSummaryView)?.endSession()
                                                    self.showSession(workout: workout,
                                                                     exercise: exercise)
            }))
            alert.show()
        }
    }
    
    // Shows the session view given a workout an exercise
    private func showSession(workout: Workout?,
                             exercise: Exercise?) {
        
        // First remove the subviews
        sectionContentView.removeAllSubviews()
        
        // Set the current session workout
        AppDelegate.sessionWorkout = workout
        if workout != nil {
            // If non-nil, safely add all of it's exercises to used session exercises
            for exercise in workout!.getExercises() {
                AppDelegate.sessionExercises.insert(exercise)
            }
        }
        if exercise != nil {
            AppDelegate.sessionExercises.insert(exercise!)
        }
        
        sessionView = WorkoutSessionView(workout: workout,
                                         frame: .zero)
        // We need to set the session delegate to know when "endSession" is called
        (sessionView as! WorkoutSessionView).workoutSessionDelegate = self
        
        if let appendedExercise = exercise {
            (sessionView as! WorkoutSessionView).workoutSessionTableView.appendDataToTableView(data: appendedExercise)
        }
        
        headerView.sectionView.showSessionButton()
        showView(sessionView!)
    }
    
    // On workout end, navigate back to the workout view.
    func endSession(workout: Workout?, exercises: List<Exercise>) {
        AppDelegate.sessionWorkout = nil
        
        for exercise in exercises {
            AppDelegate.sessionExercises.remove(exercise)
        }
        
        // Asynchronously find the new maximum for each progressionmethod
        // Done async to prevent the application from stalling while the max is being set.
        DispatchQueue.main.async {
            for exercise in exercises {
                let maxValuePerPGM = ProgressionMethod.getMaxValueForProgressionMethods(fromHistory: exercise.getExerciseHistory())
                for pgm in maxValuePerPGM.keys {
                    pgm.setMaxIfNewMax(newMax: maxValuePerPGM[pgm]!)
                }
            }
        }
        
        showContentView(viewType: SectionView.ContentViews.WORKOUTS)
        sessionView = nil
        headerView.sectionView.hideSessionButton()
    }
    
    func sessionViewChanged(toView view: UIView) {
        sessionView = view
    }
}

extension MainViewController: ShowViewDelegate {
    func showView(_ view: UIView) {
        sectionContentView.addSubview(view)
        
        NSLayoutConstraint.clingViewToView(view: view,
                                           toView: sectionContentView)
    }
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .popover
    }
}

protocol WorkoutSessionStarter {
    /*
     * Notified when a workout is starting
     */
    func startSession(workout: Workout?,
                      exercise: Exercise?)
    /*
     * Notified when a workout is ending
     */
    func endSession(workout withWorkout: Workout?, exercises: List<Exercise>)
    
    /*
     * Notified when the sessionview's mainview changed
     */
    func sessionViewChanged(toView view: UIView)
}
