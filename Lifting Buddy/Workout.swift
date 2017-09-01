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
    dynamic private var name: String?
    // The day this exercise occurs on
    dynamic private var dayOfTheWeek: String?
    // Exercises in this workout
    private var exercises: List<Exercise>
    
    // MARK: Init Functions
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = List<Exercise>()
        
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = List<Exercise>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = List<Exercise>()
        
        super.init(value: value, schema: schema)
    }
    
    // MARK: Get/Set methods for variables in this class
    
    public func getName() -> String? {
        return self.name
    }
    
    public func setName(name: String?) {
        self.name = name
    }
    
    public func getDayOfTheWeek() -> String? {
        return self.dayOfTheWeek
    }
    
    public func setDayOfTheWeek(day: String?) {
        self.dayOfTheWeek = day
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
    
    // MARK: Private functions
    
    // Remove exercise stored at an index in the int if possible
    public func removeExerciseAtIndex(index: Int) {
        if index >= 0 && index < self.exercises.endIndex {
            let realm = try! Realm()
            
            try! realm.write {
                self.exercises.remove(objectAtIndex: index)
            }
        }
    }
}
