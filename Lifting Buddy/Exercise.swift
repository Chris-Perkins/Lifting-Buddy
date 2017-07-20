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
    // The unit we're measuring in
    private var unit: String?
    // Name of this exercise
    private var name: String?
    
    // MARK: Init Functions
    
    required override init() {
        unit = nil
        name = nil
        
        super.init()
    }
    
    required override init(value: Any, schema: RLMSchema) {
        unit = nil
        name = nil
        
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
