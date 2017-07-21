//
//  Workout.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/18/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import RealmSwift
import Realm

class Workout: Object {
    // Name of this workout
    dynamic private var name: String?
    // The day this exercise occurs on
    dynamic private var dayOfTheWeek: String?
    // Exercises in this workout
    dynamic private var exercises: RLMArray<Exercise>
    
    // MARK: Init Functions
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = RLMArray(objectClassName: Exercise.className())
        
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = RLMArray(objectClassName: Exercise.className())
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.dayOfTheWeek = nil
        self.exercises = RLMArray(objectClassName: Exercise.className())
        
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
    
    public func getExercises() -> RLMArray<Exercise> {
        return self.exercises
    }
    
    public func addExercise(exercise: Exercise) {
        self.exercises.add(exercise)
    }
    
    // Remove exercise stored at an index in the int if possible
    public func removeExerciseAtIndex(index: UInt) {
        if index >= 0 && index < self.exercises.count {
            exercises.removeObject(at: index)
        }
    }
}
