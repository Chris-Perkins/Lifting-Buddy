//
//  AppDelegate.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import Realm
import RealmSwift
import GBVersionTracking

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var mainViewController: MainViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // We need this for views to not be hidden under the keyboard
        IQKeyboardManager.shared.enable = true
        // Start tracking version
        GBVersionTracking.track()
        
        // If this is the first launch EVER, build some workouts.
        if (GBVersionTracking.isFirstLaunchEver()) {
            Workout.createDefaultWorkouts()
        }
        
        let userDefaults = UserDefaults.standard
        if userDefaults.value(forKey: colorSchemeKey) == nil {
            setNewColorScheme(ColorScheme.dark)
        }
        
        // Realm migration performing is here
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion <= 0 { // original version
                    // don't have to do anything! first created.
                }
                if oldSchemaVersion < 1 { // exercisehistoryentry's now have a fixed primarykey
                    migration.enumerateObjects(ofType: ExerciseHistoryEntry.className(), { (nil, newEntry) in
                        newEntry!["identifier"] = UUID().uuidString
                    })
                }
                /*if oldSchemaVersion < 2 { // progressionmethods are given a maximum value
                    migration.enumerateObjects(ofType: ProgressionMethod.className(), { (nil, newEntry) in
                        newEntry!["maxValue"] = nil
                    })
                }*/
            }
        )
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // If user is actively in a session, we need to recalculate the maxes for any exercises
        for exercise in sessionExercises {
            exercise.recalculateProgressionMethodMaxValues()
        }
    }
}

