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
    public static var sessionWorkout: Workout? = nil
    public static var sessionExercises: Set<Exercise> = Set<Exercise>()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // We need this for views to not be hidden under the keyboard
        IQKeyboardManager.sharedManager().enable = true
        // Start tracking version
        GBVersionTracking.track()
        
        // If this is the first launch EVER, build some workouts.
        if (GBVersionTracking.isFirstLaunchEver()) {
            Workout.createDefaultWorkouts()
        }
        
        // Realm migration performing is here
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion <= 0 { // original version
                    // don't have to do anything! first created.
                }
                if oldSchemaVersion < 1 { // current version ; exercisehistoryentry's now have a fixed primarykey
                    migration.enumerateObjects(ofType: ExerciseHistoryEntry.className(), { (nil, newEntry) in
                        newEntry!["identifier"] = UUID().uuidString
                    })
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

