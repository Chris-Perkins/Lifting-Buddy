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
    // The default value (what shows up in the text fields by default
    @objc dynamic private var defaultValue: String?
    // The index of the progressionMethod. Denotes line color in graphs
    @objc dynamic private var index: String?
    // The maximum we've ever done for this progressionMethod
    @objc dynamic private var max: String?
    
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
    
    // Sets the new maximum value if this is indeed a maximum value.
    // TODO: Make this self max is indeed a float value for reusability
    // For now, this is fine since we know we can only ever set to a float value
    public func setMax(_ newMax: Float?, requiresHigherMax: Bool = true) {
        var shouldWrite = false
        
        // If we need to check if this is the highest max
        if requiresHigherMax {
            if let newMax = newMax, max == nil || newMax > max!.floatValue! {
                shouldWrite = true
            }
        } else {
            shouldWrite = true
        }
        
        if shouldWrite {
            let realm = try! Realm()
            try! realm.write {
                if let newMax = newMax {
                    max = String(describing: newMax)
                } else {
                    max = nil
                }
            }
        }
    }
    
    public func getMaxValue() -> Float? {
        return max?.floatValue
    }
    
    // MARK: Static methods
    
    public static func getMaxValueForProgressionMethods(fromHistory history: List<ExerciseHistoryEntry>) -> Dictionary<ProgressionMethod, Float> {
        var maxPerProgressionMethod = Dictionary<ProgressionMethod, Float>()
        
        // Go through every entry in the exercise. requires us to go through all history
        for historyPiece in history {
            for entry in historyPiece.exerciseInfo {
                // The progression method associated to this piece
                let pgm: ProgressionMethod = entry.progressionMethod!
                let value: Float! = entry.value!.floatValue!
                
                if !maxPerProgressionMethod.keys.contains(pgm) {
                    maxPerProgressionMethod[pgm] = entry.value!.floatValue!
                } else {
                    // If it's greater than the value in the dictionary, return it.
                    if value > maxPerProgressionMethod[pgm]! {
                        maxPerProgressionMethod[pgm] = value
                    }
                }
            }
        }
        
        return maxPerProgressionMethod
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

public class RLMExercisePiece: Object {
    @objc internal dynamic var  progressionMethod: ProgressionMethod? = nil
    @objc internal dynamic var value: String? = nil
}
