//
//  ProgressionMethod.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 8/28/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

import RealmSwift
import Realm

class ProgressionMethod: Object {
    // Assign UUID to this object
    @objc dynamic private var identifier: String = UUID().uuidString
    
    // Name of this progression method
    @objc dynamic private var name: String?
    
    // Units for reps (seconds, kilos, etc)
    @objc dynamic private var unit: String?
    @objc dynamic private var defaultValue: String?
    // The index of the progressionMethod. Denotes line color in graphs
    @objc dynamic private var index: String?
    
    public enum Unit: String {
        case WEIGHT = "weight"
        case TIME = "time"
        case DISTANCE = "distance"
        case OTHER = "other"
    }
    
    public static let unitList = ["weight", "time", "distance", "other"]
    
    // MARK: Init Functions
    
    required init() {
        self.unit = nil
        self.name = nil
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.unit = nil
        self.name = nil
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.unit = nil
        self.name = nil
        
        super.init(realm: realm, schema: schema)
    }
    
    // MARK: Primary key set up
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // MARK: Encapsulated methods
    
    public func setName(name: String?) {
        self.name = name
    }
    
    @objc public func getName() -> String? {
        return self.name
    }
    
    public func setUnit(unit: String?) {
        self.unit = unit
    }
    
    @objc public func getUnit() -> String? {
        return self.unit
    }
    
    public func setDefaultValue(defaultValue: String?) {
        self.defaultValue = defaultValue
    }
    
    @objc public func getDefaultValue() -> String? {
        return self.defaultValue
    }
    
    public func setIndex(index: Int) {
        self.index = String(index)
    }
    
    public func getIndex() -> Int? {
        guard let indexStr: String = self.index else {
            print("No string set up!")
            return nil
        }
        guard let indexInt = Int(indexStr) else {
            return nil
        }
        return indexInt
    }
}
