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
    // The day this exercise occurs on
    private var dayOfTheWeek: String?
    // Exercises in this workout
    private var exercises: [Exercise]
    
    // MARK: Init Functions
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.dayOfTheWeek = nil
        self.exercises = [Exercise]()
        
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        self.dayOfTheWeek = nil
        self.exercises = [Exercise]()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.dayOfTheWeek = nil
        self.exercises = [Exercise]()
        
        super.init(value: value, schema: schema)
    }
    
    // MARK: Get/Set methods for variables in this class
    
    public func getDayOfTheWeek() -> String? {
        return self.dayOfTheWeek
    }
    
    public func setDayOfTheWeek(day: String?) {
        self.dayOfTheWeek = day
    }
    
    public func getExercises() -> [Exercise] {
        return self.exercises
    }
    
    public func addExercise(exercise: Exercise) {
        self.exercises.append(exercise)
    }
    
    // Remove exercise stored at an index in the int if possible
    public func removeExerciseAtIndex(index: Int) {
        if index >= 0 && index < self.exercises.count {
            exercises.remove(at: index)
        }
    }
}
