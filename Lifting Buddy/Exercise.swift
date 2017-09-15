//
//  Exercise.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/18/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// A class that holds information about an exercise.

import RealmSwift
import Realm

class Exercise: Object {
    // Name of this exercise
    @objc dynamic private var name: String?
    
    // How many sets of this exercise
    @objc dynamic private var setCount: Int
    // How many reps per set
    @objc dynamic private var repCount: Int
    // Time between exercises (stored in seconds)
    @objc dynamic private var cooldownTime: Int
    
    // Progression Methods attached
    private var progressionMethods: List<ProgressionMethod>
    
    public enum Unit: String {
        case WEIGHT = "weight"
        case TIME = "time"
        case DISTANCE = "distance"
        case OTHER = "other"
    }
    
    // MARK: Init Functions
    
    required init() {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        self.progressionMethods = List<ProgressionMethod>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        self.progressionMethods = List<ProgressionMethod>()
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        self.progressionMethods = List<ProgressionMethod>()
        
        super.init(realm: realm, schema: schema)
    }
    
    // MARK: Get/Set methods for variables in this class
    
    @objc public func getRepCount() -> Int {
        return self.repCount
    }
    public func setRepCount(repCount: Int) {
        self.repCount = repCount
    }
    
    @objc public func getSetCount() -> Int {
        return self.setCount
    }
    // This variable's name is kind of funny. :)
    public func setSetCount(setCount: Int) {
        self.setCount = setCount
    }
    
    public func getName() -> String? {
        return self.name
    }
    public func setName(name: String?) {
        self.name = name
    }
    
    public func appendProgressionMethod(progressionMethod: ProgressionMethod) {
        let realm = try! Realm()
        
        try! realm.write {
            self.progressionMethods.append(progressionMethod)
        }
    }
    
    public func getProgressionMethods() -> List<ProgressionMethod> {
        return self.progressionMethods
    }

    @objc public func getCooldownTime() -> Int {
        return self.cooldownTime
    }
    @objc public func setCooldownTime(cooldownTime: Int) {
        self.cooldownTime = cooldownTime
    }
}

// Get basic info for an exercise
class ExerciseInfo {
    
    // MARK: View properties
    
    private var setCount: Int
    private var repCount: Int
    private var coolDownTime: Int
    private var progressionMethods: [ProgressionMethod]
    
    // MARK: Class inits
    
    init(exercise: Exercise) {
        self.setCount           = exercise.getSetCount()
        self.repCount           = exercise.getRepCount()
        self.coolDownTime       = exercise.getCooldownTime()
        self.progressionMethods = exercise.getProgressionMethods().toArray()
    }
    
    // MARK: Encapsulated Methods
    
    func getSetCount() -> Int {
        return self.setCount
    }
    
    func getRepCount() -> Int {
        return self.repCount
    }
    
    func getCooldownTime() -> Int {
        return self.coolDownTime
    }
    
    func getProgressionMethods() -> [ProgressionMethod] {
        return self.progressionMethods
    }
}
