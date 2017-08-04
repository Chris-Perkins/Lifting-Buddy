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

class Exercise: RLMObject {
    // Name of this exercise
    dynamic private var name: String?
    
    // How many sets of this exercise
    dynamic private var setCount: Int
    // How many reps per set
    dynamic private var repCount: Int
    // Units for reps (seconds, kilos, etc)
    dynamic private var unit: String?
    
    // MARK: Init Functions
    
    required override init() {
        self.unit = nil
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        
        super.init()
    }
    
    required override init(value: Any, schema: RLMSchema) {
        self.unit = nil
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        
        super.init(value: value, schema: schema)
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
    
    public func getUnit() -> String? {
        return self.unit
    }
    
    public func setUnit(unit: String?) {
        self.unit = unit
    }
    
    public func getName() -> String? {
        return self.name
    }
    
    public func setName(name: String?) {
        self.name = name
    }
}
