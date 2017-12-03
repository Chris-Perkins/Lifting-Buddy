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
    
    // MARK: View properties
    
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
        case WEIGHT     = "weight"
        case TIME       = "time"
        case DISTANCE   = "distance"
        case OTHER      = "other"
        case REPS       = "reps"
    }
    public static let unitList = ["weight", "time", "distance", "other", "reps"]
    
    // MARK: Init Functions
    
    required init() {
        unit = nil
        name = nil
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        unit = nil
        name = nil
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        unit = nil
        name = nil
        
        super.init(realm: realm, schema: schema)
    }
    
    // MARK: Primary key set up
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // MARK: Encapsulated methods
    
    public func setName(name: String?) {
        let realm = try! Realm()
        try! realm.write {
            self.name = name
        }
    }
    
    @objc public func getName() -> String? {
        return name
    }
    
    public func setUnit(unit: String?) {
        let realm = try! Realm()
        try! realm.write {
            self.unit = unit
        }
    }
    
    @objc public func getUnit() -> String? {
        return unit
    }
    
    public func setDefaultValue(defaultValue: String?) {
        let realm = try! Realm()
        try! realm.write {
            self.defaultValue = defaultValue
        }
    }
    
    @objc public func getDefaultValue() -> String? {
        return defaultValue
    }
    
    public func setIndex(index: Int) {
        let realm = try! Realm()
        try! realm.write {
            self.index = String(index)
        }
    }
    
    public func getIndex() -> Int? {
        guard let indexStr: String = index else {
            return nil
        }
        guard let indexInt = Int(indexStr) else {
            fatalError("The index associated to a progressionmethod is not an int")
        }
        return indexInt
    }
    
    // MARK: Default workout creation
    
    // Create a reps pgm
    public static func createRepsPGM() -> ProgressionMethod {
        // Progression method holding reps
        let repsPGM = ProgressionMethod()
        repsPGM.setName(name: "Reps")
        repsPGM.setUnit(unit: ProgressionMethod.Unit.REPS.rawValue.lowercased())
        
        return repsPGM
    }
    
    // Create a weight pgm
    public static func createWeightPGM() -> ProgressionMethod {
        let weightPGM = ProgressionMethod()
        weightPGM.setName(name: "Weight")
        weightPGM.setUnit(unit: ProgressionMethod.Unit.WEIGHT.rawValue.lowercased())
        
        return weightPGM
    }
}
