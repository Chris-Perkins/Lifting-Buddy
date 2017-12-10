//
//  Workout.swift
//  Lifting Buddy
//
//  Created by Christopher Perkins on 7/18/17.
//  Copyright © 2017 Christopher Perkins. All rights reserved.
//

/// Class holding information about a workout
/// Workouts contain exercises.

import RealmSwift
import Realm

class Workout: Object {
    // MARK: View properties
    
    // Assign UUID to this object
    @objc dynamic private var identifier: String = UUID().uuidString
    
    // Name of this workout
    @objc dynamic private var name: String?
    // The last day this workout was done
    @objc dynamic private var dateLastDone: Date?
    // The current streak
    @objc dynamic private var curStreak: Int
    // The maximum streak a user obtained on this exercise
    @objc dynamic private var maxStreak: Int
    // The number of times we completed this workout
    @objc dynamic private var completedCount: Int
    
    // The day this exercise occurs on
    private var daysOfTheWeek: List<RLMBool>
    // Exercises in this workout
    private var exercises: List<Exercise>
    
    // MARK: Init Functions
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        name = nil
        curStreak = 0
        maxStreak = 0
        completedCount = 0
        
        daysOfTheWeek = List<RLMBool>()
        exercises = List<Exercise>()
        
        super.init(realm: realm, schema: schema)
    }
    
    required init() {
        name = nil
        curStreak = 0
        maxStreak = 0
        completedCount = 0
        
        daysOfTheWeek = List<RLMBool>()
        exercises = List<Exercise>()
        
        super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        name = nil
        curStreak = 0
        maxStreak = 0
        completedCount = 0
        
        daysOfTheWeek = List<RLMBool>()
        exercises = List<Exercise>()
        
        super.init(value: value, schema: schema)
    }
    
    // MARK: Primary key set up
    
    override static func primaryKey() -> String? {
        return "identifier"
    }
    
    // MARK: Information Functions
    
    // Resets the streak if we missed a day
    public func checkAndUpdateStreakIfNecessary() {
        // No use in checking if we have never done the workout.
        if dateLastDone == nil {
            return
        }
        
        // TODO: Rework how streaks are done. This is bad.
        let today = Date(timeIntervalSinceNow: 0)
        let cal = Calendar(identifier: .gregorian)
        
        // Sub one from below lines because Apple thought it'd be a good idea to make these 1-indexed.
        // AKA: Sunday = 1 becomes Sunday = 0
        let day = cal.component(.weekday, from: today) - 1
        let weekdayLastDone = cal.component(.weekday, from: dateLastDone!) - 1
        
        for i in 0...6 {
            // Do not reset if we did our exercise on a non-scheduled date.
            if cal.dateComponents(Set([Calendar.Component.day]), from: dateLastDone!, to: today).day! == i {
                return
            }
            
            // Don't check from last week if we're on 0. So, we continue.
            if i == 0 { continue }
            
            if daysOfTheWeek[(7 + day - i) % 7].value {
                if cal.dateComponents(Set([Calendar.Component.day]), from: dateLastDone!, to: today).day! > 7 ||
                    weekdayLastDone != (7 + day - i) % 7 {
                    
                    // If we ended our streak, curStreak is 0. SAD!
                    let realm = try! Realm()
                    try! realm.write {
                        curStreak = 0
                    }
                }
                
                // Return as soon as we got to the first day that's previous to this one
                return
            }
        }
    }
    
    // MARK: Encapsulated Methods
    
    @objc public func getName() -> String? {
        return name
    }
    
    public func setName(name: String?) {
        let realm = try! Realm()
        
        try! realm.write {
            self.name = name
        }
    }
    
    public func getsDayOfTheWeek() -> List<RLMBool> {
        return daysOfTheWeek
    }
    
    public func setDaysOfTheWeek(daysOfTheWeek: List<RLMBool>) {
        let realm = try! Realm()
        try! realm.write {
            for dayValue in self.daysOfTheWeek {
                realm.delete(dayValue)
            }
            for dayValue in daysOfTheWeek {
                realm.add(dayValue)
                self.daysOfTheWeek.append(dayValue)
            }
        }
    }
    
    public func getExercises() -> List<Exercise> {
        return exercises
    }
    
    public func addExercise(exercise: Exercise) {
        let realm = try! Realm()
        
        try! realm.write {
            exercises.append(exercise)
        }
    }
    
    public func removeExercies() {
        let realm = try! Realm()
        
        try! realm.write {
            exercises.removeAll()
        }
    }
    
    // returns whether or not the workout is scheduled for today
    public func getIfTodayWorkout() -> Bool {
        if daysOfTheWeek.count == 0 {
            return false
        }
        
        let date = Date()
        let formatter = NSDate.getDateFormatter()
        return daysOfTheWeek[NSDate().getDayOfWeek(formatter.string(from: date))! - 1].value
    }
    
    // Returns the date we last did this workout
    public func getDateLastDone() -> Date? {
        return dateLastDone
    }
    
    // Sets the last date we've done a workout
    public func setDateLastDone(date: Date?) {
        let realm = try! Realm()
        try! realm.write {
            dateLastDone = date
        }
    }
    
    // Increases the number of times we've done this workout.
    // Also increases the streak count and checks if we hit a new streak
    public func incrementWorkoutCount() {
        let realm = try! Realm()
        try! realm.write {
            curStreak += 1
            completedCount += 1
            
            // check if we've increases the maximum streak
            if curStreak > maxStreak {
                maxStreak = curStreak
            }
        }
    }
    
    public func getCurSteak() -> Int {
        return curStreak
    }
    
    // Remove exercise stored at an index in the int if possible
    public func removeExerciseAtIndex(index: Int) {
        if index >= 0 && index < exercises.endIndex {
            let realm = try! Realm()
            
            try! realm.write {
                exercises.remove(at: index)
            }
        }
    }
    
    public static func getSortedWorkoutArray(workouts: AnyRealmCollection<Workout>) -> [Workout] {
        
        let sortedWorkouts = workouts.sorted(by: {
            // If #1's workout is today and #2's is not, then it's "less".
            // If #1 and #2 are both either today or not today, then determine by name.
            // Otherwise, #1 is "greater".
            ($0.getIfTodayWorkout() && !($1.getIfTodayWorkout())) ||
                ($0.getIfTodayWorkout() == $1.getIfTodayWorkout() && ($0.getName())! < ($1.getName())!)
        })
        
        return sortedWorkouts
    }
    
    /* Updates our streak counter by resetting the streak
     * if we missed a day of the workout.
     */
    public static func updateAllStreaks() {
        let realm = try! Realm()
        
        for workout in realm.objects(Workout.self) {
            workout.checkAndUpdateStreakIfNecessary()
        }
    }
    
    // Creates a chest, back, and leg day workout.
    public static func createDefaultWorkouts() {
        Workout.createChestDayWorkout()
        Workout.createLegDayWorkout()
    }
    
    // Creates a chest day workout
    private static func createChestDayWorkout() {
        let realm = try! Realm()
        
        let workout = Workout()
        workout.setName(name: "Arm Day")
        
        // Set this workout to activate Monday
        let mondayList = List<RLMBool>()
        for i in 0...7 {
            let dayBool = RLMBool()
            dayBool.value = i == 1 // Set to true on Monday
            mondayList.append(dayBool)
        }
        
        workout.setDaysOfTheWeek(daysOfTheWeek: mondayList)
        
        let benchPress = Exercise()
        benchPress.setName(name: "Flat Barbell Bench Press")
        benchPress.setSetCount(setCount: 5)
        
        // Progression method holding reps
        var repsPGM = ProgressionMethod.createRepsPGM()
        repsPGM.setDefaultValue(defaultValue: "5")
        repsPGM.setIndex(index: 0)
        
        // Progression method holding weight
        var weightPGM = ProgressionMethod.createWeightPGM()
        weightPGM.setIndex(index: 1)
        
        // Bench press tracked by reps & weight
        benchPress.appendProgressionMethod(progressionMethod: repsPGM)
        benchPress.appendProgressionMethod(progressionMethod: weightPGM)
        
        // Add bench press to this workout and to the realm
        try! realm.write {
            realm.add(repsPGM)
            realm.add(weightPGM)
            realm.add(benchPress)
        }
        workout.addExercise(exercise: benchPress)
        
        // Incline bench workout
        let inclineBench = Exercise()
        inclineBench.setName(name: "Incline Barbell Bench Press")
        inclineBench.setSetCount(setCount: 5)
        
        // Progression method holding reps
        repsPGM = ProgressionMethod.createRepsPGM()
        repsPGM.setDefaultValue(defaultValue: "5")
        repsPGM.setIndex(index: 0)
        
        // Progression method holding weight
        weightPGM = ProgressionMethod.createWeightPGM()
        weightPGM.setIndex(index: 1)
        
        // incline press tracked by reps & weight
        inclineBench.appendProgressionMethod(progressionMethod: repsPGM)
        inclineBench.appendProgressionMethod(progressionMethod: weightPGM)
        
        // Add incline bench to this workout and to the realm
        try! realm.write {
            realm.add(repsPGM)
            realm.add(weightPGM)
            realm.add(inclineBench)
        }
        workout.addExercise(exercise: inclineBench)
        
        // Pushups
        let pushups = Exercise()
        pushups.setName(name: "Pushups")
        pushups.setSetCount(setCount: 3)
        
        // Progression method holding reps
        repsPGM = ProgressionMethod.createRepsPGM()
        repsPGM.setDefaultValue(defaultValue: "10")
        repsPGM.setIndex(index: 0)
        
        // Crossovers tracked by reps and weight
        pushups.appendProgressionMethod(progressionMethod: repsPGM)
        
        // Add pushups to our workout
        try! realm.write {
            realm.add(repsPGM)
            realm.add(pushups)
        }
        workout.addExercise(exercise: pushups)
        
        try! realm.write {
            realm.add(workout)
        }
    }
    
    // Creates a leg day workout
    private static func createLegDayWorkout() {
        let realm = try! Realm()
        
        let workout = Workout()
        workout.setName(name: "Leg and Abs Day")
        
        // Set this workout to activate Friday
        let fridayList = List<RLMBool>()
        for i in 0...7 {
            let dayBool = RLMBool()
            dayBool.value = i == 5 // Set to true on Friday
            fridayList.append(dayBool)
        }
        
        workout.setDaysOfTheWeek(daysOfTheWeek: fridayList)
        
        // Squats exercise
        let squats = Exercise()
        squats.setName(name: "Squats")
        squats.setSetCount(setCount: 5)
        
        var repsPGM = ProgressionMethod.createRepsPGM()
        repsPGM.setIndex(index: 0)
        repsPGM.setDefaultValue(defaultValue: "5")
        
        var weightPGM = ProgressionMethod.createWeightPGM()
        weightPGM.setIndex(index: 1)
        
        squats.appendProgressionMethod(progressionMethod: repsPGM)
        squats.appendProgressionMethod(progressionMethod: weightPGM)
        
        try! realm.write {
            realm.add(repsPGM)
            realm.add(weightPGM)
            realm.add(squats)
        }
        
        workout.addExercise(exercise: squats)
        
        // Leg Curls Exercise
        let legCurls = Exercise()
        legCurls.setName(name: "Leg Curls")
        legCurls.setSetCount(setCount: 3)
        
        repsPGM = ProgressionMethod.createRepsPGM()
        repsPGM.setIndex(index: 0)
        repsPGM.setDefaultValue(defaultValue: "10")
        
        weightPGM = ProgressionMethod.createWeightPGM()
        weightPGM.setIndex(index: 0)
        
        legCurls.appendProgressionMethod(progressionMethod: repsPGM)
        legCurls.appendProgressionMethod(progressionMethod: weightPGM)
        
        try! realm.write {
            realm.add(repsPGM)
            realm.add(weightPGM)
            realm.add(legCurls)
        }
        
        workout.addExercise(exercise: legCurls)
        
        // Planks
        
        let planks = Exercise()
        planks.setName(name: "Planks")
        planks.setSetCount(setCount: 1)
        
        let timePGM = ProgressionMethod()
        timePGM.setDefaultValue(defaultValue: "3")
        timePGM.setName(name: "Time")
        timePGM.setUnit(unit: ProgressionMethod.Unit.TIME.rawValue.lowercased())
        timePGM.setIndex(index: 0)
        
        planks.appendProgressionMethod(progressionMethod: timePGM)
        
        try! realm.write {
            realm.add(planks)
            realm.add(timePGM)
        }
        
        workout.addExercise(exercise: planks)
        
        try! realm.write {
            realm.add(workout)
        }
    }
}

// Question:
// "CHRIS?! CHRIS WHY DID YOU DO THIS?"
// Answer:
// Because realm does not support RLMArrays/Lists of primitive types.
public class RLMBool: Object {
    @objc public dynamic var value: Bool = false
}
