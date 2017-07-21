//
//  Exercise.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/18/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import RealmSwift
import Realm

class Exercise: RLMObject {
    // Name of this exercise
    dynamic var name: String?
    
    // How many sets of this exercise
    dynamic var setCount: Int
    // How many reps per set
    dynamic var repCount: Int
    // Units for reps (seconds, kilos, etc)
    dynamic var unit: String?
    
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
