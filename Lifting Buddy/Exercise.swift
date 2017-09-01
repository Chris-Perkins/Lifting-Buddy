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
    dynamic private var name: String?
    
    // How many sets of this exercise
    dynamic private var setCount: Int
    // How many reps per set
    dynamic private var repCount: Int
    // Progression Methods attached
    private var progressionMethods: RLMArray = RLMArray(objectClassName: "ProgressionMethod")
    // Time between exercises (stored in seconds)
    dynamic private var cooldownTime: Int
    
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
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        fatalError("init(realm:schema:) has not been implemented")
    }
    
    // MARK: Get/Set methods for variables in this class
    
    public func getRepCount() -> Int {
        return self.repCount
    }
    public func setRepCount(repCount: Int) {
        self.repCount = repCount
    }
    
    public func getSetCount() -> Int {
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
            self.progressionMethods.add(progressionMethod)
        }
    }
    
    public func getProgressionMethods() -> RLMArray<RLMObject> {
        return self.progressionMethods
    }
    
    public func getCooldownTime() -> Int {
        return self.cooldownTime
    }
    public func setCooldownTime(cooldownTime: Int) {
        self.cooldownTime = cooldownTime
    }
}
