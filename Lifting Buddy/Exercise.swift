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
    // MARK: View properties
    
    // Assign UUID to this object
    @objc dynamic private var identifier: String = UUID().uuidString
    
    // Name of this exercise
    @objc dynamic private var name: String?
    // How many sets of this exercise
    @objc dynamic private var setCount: Int
    // How many reps per set
    @objc dynamic private var repCount: Int
    // Time between exercises (stored in seconds)
    @objc dynamic private var cooldownTime: Int
    
    // The history attached to this exercise
    private var exerciseHistory: List<ExerciseHistoryEntry>
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
        self.exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        self.progressionMethods = List<ProgressionMethod>()
        self.exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        self.name = nil
        self.setCount = 0
        self.repCount = 0
        self.cooldownTime = 0
        self.progressionMethods = List<ProgressionMethod>()
        self.exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init(realm: realm, schema: schema)
    }
    
    // MARK: Primary key set up
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // MARK: Encapsulated methods
    
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
    
    @objc public func getName() -> String? {
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
    
    public func getExerciseHistory() -> List<ExerciseHistoryEntry> {
        return self.exerciseHistory
    }
    
    public func appendExerciseHistoryEntry(exerciseHistoryEntry: ExerciseHistoryEntry) {
        let realm = try! Realm()
        try! realm.write {
            self.exerciseHistory.append(exerciseHistoryEntry)
        }
    }

    @objc public func getCooldownTime() -> Int {
        return self.cooldownTime
    }
    @objc public func setCooldownTime(cooldownTime: Int) {
        self.cooldownTime = cooldownTime
    }
    
    // MARK: Static Methods
    
    // Returns a list of sorted exercises by name
    public static func getSortedExerciseArray(exercises: AnyRealmCollection<Exercise>) -> [Exercise] {
        let sortedExercises = exercises.sorted(by: {
            // If #1's workout is today and #2's is not, then it's "less".
            // If #1 and #2 are both either today or not today, then determine by name.
            // Otherwise, #1 is "greater".
            ($0.getName() != $1.getName() && ($0.getName())! < ($1.getName())!)
        })
        
        return sortedExercises
    }
}

// Question:
// "CHRIS?! CHRIS OH WHY DID YOU DO THIS?"
// Answer:
// Because realm does not support RLMArrays/Lists of primitive types.

public class RLMExercisePiece: Object {
    @objc internal dynamic var  progressionMethod: ProgressionMethod? = nil
    @objc internal dynamic var value: String? = nil
}

public class ExerciseHistoryEntry: Object {
    @objc public dynamic var date: Date?
    public var exerciseInfo: List<RLMExercisePiece> = List<RLMExercisePiece>()
}
