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
    
    // We can't modify the core properties if being used in an active session
    public var canModifyCoreProperties: Bool {
        return !AppDelegate.sessionExercises.contains(self)
    }
    
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
        name = nil
        setCount = 0
        repCount = 0
        cooldownTime = 0
        
        progressionMethods = List<ProgressionMethod>()
        exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        name = nil
        setCount = 0
        repCount = 0
        cooldownTime = 0
        progressionMethods = List<ProgressionMethod>()
        exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        name = nil
        setCount = 0
        repCount = 0
        cooldownTime = 0
        progressionMethods = List<ProgressionMethod>()
        exerciseHistory = List<ExerciseHistoryEntry>()
        
        super.init(realm: realm, schema: schema)
    }
    
    // MARK: Primary key set up
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // MARK: General functions
    
    // Recalculates the maximum value for each progression method
    public func recalculateProgressionMethodMaxValues() {
        // Asynchronously find the new maximum for each progressionmethod
        // Done async to prevent the application from stalling while the max is being set.
        DispatchQueue.main.async {
            let maxPerProgressionMethod = ProgressionMethod.getMaxValueForProgressionMethods(fromHistory: self.getExerciseHistory())
            for pgm in self.getProgressionMethods() {
                pgm.setMax(maxPerProgressionMethod[pgm], requiresHigherMax: false)
            }
        }
    }
    
    // MARK: Encapsulated methods
    
    @objc public func getSetCount() -> Int {
        return setCount
    }
    
    // This variable's name is kind of funny. :)
    public func setSetCount(setCount: Int) {
        let realm = try! Realm()
        try! realm.write {
            self.setCount = setCount
        }
    }
    
    @objc public func getName() -> String? {
        return name
    }
    
    public func setName(name: String?) {
        let realm = try! Realm()
        try! realm.write {
            self.name = name
        }
    }
    
    public func getProgressionMethods() -> List<ProgressionMethod> {
        return progressionMethods
    }
    
    // Appends a progressionmethod to this exercise
    public func appendProgressionMethod(progressionMethod: ProgressionMethod) {
        let realm = try! Realm()
        try! realm.write {
            progressionMethods.append(progressionMethod)
        }
    }
    
    // Removes all progression methods
    public func removeProgressionMethods() {
        let realm = try! Realm()
        try! realm.write {
            progressionMethods.removeAll()
        }
    }
    
    public func getExerciseHistory() -> List<ExerciseHistoryEntry> {
        return exerciseHistory
    }
    
    // Adds an entry to this exercise
    public func appendExerciseHistoryEntry(_ exerciseHistoryEntry: ExerciseHistoryEntry) {
        let realm = try! Realm()
        try! realm.write {
            exerciseHistory.append(exerciseHistoryEntry)
        }
    }
    
    public func removeExerciseHistoryEntry(_ removeEntry: ExerciseHistoryEntry) {
        let realm = try! Realm()
        try! realm.write {
            /*
                We go in reverse because it's MOST likely we're calling this from
                an session, where all entries are newly created (in the back).
            */
            for (index, entry) in exerciseHistory.enumerated().reversed() {
                if entry == removeEntry {
                    exerciseHistory.remove(at: index)
                    // Only delete if this is the right entry.
                    realm.delete(entry)
                    break
                }
            }
        }
    }
    
    // Removes the given progressionMethods from the exercise.
    public func removeProgressionMethodsFromHistory(progressionMethodsToDelete: Set<ProgressionMethod>) {
        let realm = try! Realm()
        
        // We have to dive down to delete any progression method trace.
        // Don't want to store data if we don't have to anymore!
        for (indexEntry, entry) in exerciseHistory.enumerated().reversed() {
            for (indexDataPiece, dataPiece) in entry.exerciseInfo.enumerated().reversed() {
                if let progressionMethod = dataPiece.progressionMethod {
                    if progressionMethodsToDelete.contains(progressionMethod) {
                        try! realm.write {
                            entry.exerciseInfo.remove(at: indexDataPiece)
                            
                            
                            if entry.exerciseInfo.isEmpty {
                                exerciseHistory.remove(at: indexEntry)
                            }
                        } // closes realm.write
                    }
                } // closes if check
            }
        } // closes for loop # 1
    }
    
    @objc public func getCooldownTime() -> Int {
        return cooldownTime
    }
    @objc public func setCooldownTime(cooldownTime: Int) {
        let realm = try! Realm()
        try! realm.write {
            self.cooldownTime = cooldownTime
        }
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

public class ExerciseHistoryEntry: Object {
    
    @objc public dynamic var date: Date?
    public var exerciseInfo: List<RLMExercisePiece> = List<RLMExercisePiece>()
    
    // MARK: Primary key set up
    // Assign UUID to this object as primary key
    @objc dynamic private var identifier: String = UUID().uuidString
    
    override public static func primaryKey() -> String? {
        return "identifier"
    }
}
