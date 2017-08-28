//
//  ProgressionMethod.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/28/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import RealmSwift
import Realm

class ProgressionMethod: RLMObject {
    // Name of this progression method
    dynamic private var name: String?
    
    // Units for reps (seconds, kilos, etc)
    dynamic private var unit: String?
    
    public enum Unit: String {
        case WEIGHT = "weight"
        case TIME = "time"
        case DISTANCE = "distance"
        case OTHER = "other"
    }
    
    // MARK: Init Functions
    
    required override init() {
        self.unit = nil
        self.name = nil
        
        super.init()
    }
    
    required override init(value: Any, schema: RLMSchema) {
        self.unit = nil
        self.name = nil
        
        super.init(value: value, schema: schema)
    }
    
    // MARK: Encapsulated methods
    
    public func getUnit() -> String? {
        return self.unit
    }
    public func setUnit(unit: String?) {
        self.unit = unit
    }
}

