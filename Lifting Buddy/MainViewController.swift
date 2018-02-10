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
import StoreKit

// MARK: ViewController Declaration

class MainViewController: UIViewController {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var sectionContentView: UIView!
    @IBOutlet weak var messageContainerView: UIView!
    
    // MARK: View properties
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        switch (activeColorScheme) {
        case .light:
            return .default
        case .dark:
            return .lightContent
        }
    }
    
    // Cache the views so data is stored between user navigation.
    
    // The session view is special since it's main view can change.
    // Possibilities are workoutsession or summaryscreen.
    private var sessionView: UIView? = nil
    private var workoutView: WorkoutsView? = nil
    private var exercisesView: ExercisesView? = nil
    
    // MARK: Override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .lightestBlackWhiteColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Done to fix coloring scheme updates not working unless app restarted
        view.layoutAllSubviews()
        
        if GBVersionTracking.firstInstalledVersion() <= "1.2" &&
            GBVersionTracking.isFirstLaunchForVersion() {
            SKStoreReviewController.requestReview()
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
            sessionView.layoutAllSubviews()
            showView(sessionView)
            
        case SectionView.ContentViews.WORKOUTS:
            if workoutView == nil {
                workoutView = WorkoutsView(frame: .zero)
            }
            workoutView?.layoutAllSubviews()
            showView(workoutView!)
            
        case SectionView.ContentViews.EXERCISES:
            if exercisesView == nil {
                exercisesView = ExercisesView(frame: .zero)
            }
            exercisesView?.layoutAllSubviews()
            showView(exercisesView!)
        }
    }
    
    // MARK: Event functions
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
}

// MARK: WorkoutSessionStarter Extension

extension MainViewController: WorkoutSessionStarter {
    func startSession(workout: Workout?,
                      exercise: Exercise?) {
        if sessionView == nil {
            self.showSession(workout: workout,
                             exercise: exercise)
        } else {
            let alert = CDAlertView(title: NSLocalizedString("Message.QuitSession.Title", comment: ""),
                                    message: NSLocalizedString("Message.QuitSession.Desc", comment: ""),
                                    type: CDAlertViewType.warning)
            alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Cancel", comment: ""),
                                                font: nil,
                                                textColor: UIColor.white,
                                                backgroundColor: UIColor.niceBlue, handler: nil))
            alert.add(action: CDAlertViewAction(title: NSLocalizedString("Button.Quit", comment: ""),
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
        sessionWorkout = workout
        if workout != nil {
            // If non-nil, safely add all of it's exercises to used session exercises
            for exercise in workout!.getExercises() {
                sessionExercises.insert(exercise)
            }
        }
        if exercise != nil {
            sessionExercises.insert(exercise!)
        }
        sessionStartDate = Date(timeIntervalSinceNow: 0)
        
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
        sessionWorkout = nil
        sessionStartDate = nil
        
        for exercise in exercises {
            sessionExercises.remove(exercise)
            // Recalculate the max for each since they may need updating
            exercise.recalculateProgressionMethodMaxValues()
        }
        
        showContentView(viewType: SectionView.ContentViews.WORKOUTS)
        sessionView = nil
        headerView.sectionView.hideSessionButton()
    }
    
    func sessionViewChanged(toView view: UIView) {
        sessionView = view
    }
}

// MARK: ShowViewDelegate Extension

extension MainViewController: ShowViewDelegate {
    func showView(_ view: UIView) {
        sectionContentView.addSubview(view)
        
        NSLayoutConstraint.clingViewToView(view: view,
                                           toView: sectionContentView)
    }
}

// MARK: ExerciseDisplayer Extension

extension MainViewController: ExerciseDisplayer {
    func displayExercise(_ exercise: Exercise) {
        headerView.sectionView.imitateButtonPress(forButton: headerView.sectionView.exercisesButton)
        exercisesView?.selectExercise(exercise: exercise)
    }
}

// MARK: MessageDisplayer Extension

extension MainViewController: MessageDisplayer {
    func displayMessage(_ message: Message) {
        let messageV = MessageView(withMessage: message, andHeight: messageContainerView.frame.height)
        
        UIView.slideView(messageV, overView: messageContainerView)
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            UIView.animate(withDuration: 0.25, animations: {
                messageV.alpha = 0
            })
        }
    }
    
    func messageQueueStarted() {
        UIView.animate(withDuration: 0.25) {
            self.headerView.aboutButton.alpha = 0
            self.headerView.titleBar.alpha    = 0
        }
    }
    
    func messageQueueEnded() {
        UIView.animate(withDuration: 0.25) {
            self.headerView.aboutButton.alpha = 1
            self.headerView.titleBar.alpha    = 1
        }
    }
}
