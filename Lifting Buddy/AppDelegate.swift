//
//  AppDelegate.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/14/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import IQKeyboardManagerSwift
import Realm
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    // TODO: Remove when purging old files
    var mainViewController: MainViewController?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // We need this for views to not be hidden under the keyboard
        IQKeyboardManager.shared.enable = true

        // TODO: Migrate to new database
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

        let mainVC = LBSessionTabBarViewController(nibName: nil, bundle: nil)

        // MARK: - TEST LOGIC STARTS
        let vc1 = UINavigationController(navigationBarClass: LBNavigationBar.self, toolbarClass: nil)
        let pushedVC1 = TestVC()
        pushedVC1.title = "View Controller 1"
        pushedVC1.view.backgroundColor = UIColor.white
        vc1.pushViewController(pushedVC1, animated: true)
        mainVC.addTab(displayItem: UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1), viewController: vc1)

        let vc2 = UINavigationController(navigationBarClass: LBNavigationBar.self, toolbarClass: nil)
        let pushedVC2 = LBWorkoutsViewController()
        pushedVC2.title = "View Controller 2"
        vc2.pushViewController(pushedVC2, animated: true)
        mainVC.addTab(displayItem: UITabBarItem(tabBarSystemItem: .favorites, tag: 2), viewController: vc2)
        // MARK: - TEST LOGIC ENDS

        window = UIWindow()
        window?.makeKeyAndVisible()
        window?.rootViewController = mainVC
        
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // If user is actively in a session, we need to recalculate the maxes for any exercises
        for exercise in sessionExercises {
            exercise.recalculateProgressionMethodMaxValues()
        }
    }
}

