//
//  Workout.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/18/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Class holding information about a workout
/// Workouts contain exercises.

import RealmSwift
import Realm

class Workout: Object {
    // MARK: View properties
    
    // Name of this workout
    @objc dynamic private var name: String?
    // The last day this workout was done
    @objc dynamic private var dateLastDone: Date?
    // The current streak
    @objc dynamic private var curStreak: Int
    
    // The day this exercise occurs on
    private var daysOfTheWeek: List<RLMBool>
    // Exercises in this workout
    private var exercises: List<Exercise>
    
    // MARK: Init Functions
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.name = nil
        self.curStreak = 0
        
        self.daysOfTheWeek = List<RLMBool>()
        self.exercises = List<Exercise>()
        
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        self.name = nil
        self.curStreak = 0
        
        self.daysOfTheWeek = List<RLMBool>()
        self.exercises = List<Exercise>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.curStreak = 0
        
        self.daysOfTheWeek = List<RLMBool>()
        self.exercises = List<Exercise>()
        
        super.init(value: value, schema: schema)
    }
    
    // MARK: Get/Set methods for variables in this class
    
    @objc public func getName() -> String? {
        return self.name
    }
    
    public func setName(name: String?) {
        self.name = name
    }
    
    public func getsDayOfTheWeek() -> List<RLMBool> {
        return self.daysOfTheWeek
    }
    
    public func setDaysOfTheWeek(daysOfTheWeek: List<RLMBool>) {
        self.daysOfTheWeek = daysOfTheWeek
    }
    
    public func getExercises() -> List<Exercise> {
        return self.exercises
    }
    
    public func addExercise(exercise: Exercise) {
        let realm = try! Realm()
        
        try! realm.write {
            self.exercises.append(exercise)
        }
    }
    
    // returns whether or not the workout is scheduled for today
    public func getIfTodayWorkout() -> Bool {
        if daysOfTheWeek.count == 0 {
            return false
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return daysOfTheWeek[NSDate().getDayOfWeek(formatter.string(from: date))! - 1].value
    }
    
    public func setDateLastDone(date: Date?) {
        let realm = try! Realm()
        try! realm.write {
            self.dateLastDone = date
        }
    }
    
    public func incrementCurStreak() {
        let realm = try! Realm()
        try! realm.write {
            self.curStreak += 1
        }
    }
    
    public func getCurSteak() -> Int {
        return self.curStreak
    }
    
    // Remove exercise stored at an index in the int if possible
    public func removeExerciseAtIndex(index: Int) {
        if index >= 0 && index < self.exercises.endIndex {
            let realm = try! Realm()
            
            try! realm.write {
                self.exercises.remove(at: index)
            }
        }
    }
    
    public static func getSortedWorkoutArray(workouts: AnyRealmCollection<Workout>) -> [Workout] {
        let sortedWorkouts = workouts.sorted(by: {
            // If #1's workout is today and #2's is not, then it's "less".
            // If #1 and #2 are both either today or not today, then determine by name.
            // Otherwise, #1 is "greater".
            ($0.getIfTodayWorkout() && !($1.getIfTodayWorkout())) ||
            ($0.getIfTodayWorkout() == $1.getIfTodayWorkout() && ($0.getName())! < ($1.getName())!)
        })
        
        return sortedWorkouts
    }
}

// Question:
// "CHRIS?! CHRIS OH WHY DID YOU DO THIS?"
// Answer:
// Because realm does not support RLMArrays/Lists of primitive types.
public class RLMBool: Object {
    @objc public dynamic var value: Bool = false
}

