//
//  data_stores.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 26/09/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts
/*
 Codable lets Swift automatically encode/decode your types to/from external representations (like Firestore/JSON).
 By default, Swift will synthesize this behavior if your properties map 1:1 to keys and types in the data.
*/

struct set_data: Identifiable, Codable, Equatable {
    var id = UUID()
    var reps: Double?
    var weight: Double?
    var durationSeconds: TimeInterval?
    var rest: TimeInterval?
    var rpe: Double?
}

struct exercise_data: Identifiable, Codable, Equatable {
    var id = UUID()
    var exerciseName: String = ""
    var activityID: UUID?
    var sets: [set_data] = []

}

struct workout_data: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var date: Date
    var exercises: [exercise_data]
    var notes: String = ""
    
    
    enum CodingKeys: String, CodingKey {
        /*
         CodingKeys defines the mapping between my properties and external keys.
         Each case corrresponds to a property I want to encode/decode. In this case,
         extrinsic names (in firebase) are the same as my intrinsice names. If the
         extrinsic names were different, could define like "case name = "workout_name".
         */
        case id
        case name
        case date
        case exercises
        case notes
    }

    init(from decoder: Decoder) throws {
        /*
         Custom initialiser which can provide default keys, convert mis-matched types,
         decode nested structures and keep properties non-optional.
         */
        
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // DocumentID is typically filled by Firestore; should be safe to decode
        self.id = try c.decodeIfPresent(String.self, forKey: .id)

        // Required fields — throw if missing/wrong type
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? "" // or `try c.decode(String.self, forKey: .name)` if truly required
        
        self.date = try c.decode(Date.self, forKey: .date)
        self.exercises = try c.decode([exercise_data].self, forKey: .exercises)

        // Optional-with-default — if the key is missing/null, use ""
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

extension workout_data {
    init(
        id: String? = nil,
        name: String = "",
        date: Date,
        exercises: [exercise_data],
        notes: String = ""
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.exercises = exercises
        self.notes = notes
    }
}

struct workout_data_json: Codable {
    var name: String = ""
    var date: Date
    var exercises: [exercise_data]
    var notes: String = ""
}

struct template_data: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String = ""
    var date: Date
    var exercises: [exercise_data]
    var notes: String = ""
}

struct activities_list: Codable, Identifiable {
    @DocumentID var id: String?
    var activities: [exercise_definition]
}

struct exercise_definition: Codable, Identifiable {
    var id = UUID()
    var name: String = ""
    var activityClass: String = ""
    var instructions: String = ""
    var targetedMuscleGroups: [String]
    var muscleGroupWeightings: [Int]
    var isIso: Bool = false
    var isUnilateral: Bool = false
}

// MARK: - Extension to calculate totals
extension workout_data {
    var totalReps: Double {
        exercises
            .flatMap { $0.sets }
            .compactMap {$0.reps} // convert from String → Int
            .reduce(0, +)
    }
}


extension Array where Element == workout_data {
    /*
     Get a non-repeating string array of all previously performed exercises
     */
    var exerciseNames: [String] {
        // Declare imutable array made from executing the closure for each element of self
        // Here $0 is the first parameter passed into the closure (and only as .map only passes one)
        let nested = self.map { $0.exercises.map { $0.exerciseName } }
        
        // nested is an array of arrays, flatten into one array
        let allNames = nested.flatMap { $0 }
        
        // Remove duplicates + sort
        return Set(allNames).sorted()
    }
}

extension Array where Element == workout_data {
    /*
     Get a tuple array representing the entire impulse history of specified exerciseName
     */
    func general_history(for exerciseName: String) -> [(date: Date, exercise: exercise_data)] { //defines a function with a tuple array output
        //Iterates over workout_data
        self.compactMap { workout in
            // Find if an exercise in this workout matches the name
            if let exercise = workout.exercises.first(where: { $0.exerciseName == exerciseName }) {
                return (workout.date, exercise)
            }
            return nil
        }
        //.sorted passes two args into closure and compares which one to put before the other. .date is needed to specify I am wanting to compare the date params of the tuple (not the names).
        .sorted { $0.date < $1.date } // chronological order
    }
}

extension Array where Element == workout_data {
    /*
     Get a tuple array representing the entire impulse history of specified exerciseName
     */
    func impulse_history(for exerciseName: String) -> [(date: Date, impulse: Double)] { //defines a function with a tuple array output
        //Iterates over workout_data
        self.compactMap { workout in
            // Find if an exercise in this workout matches the name
            if let exercise = workout.exercises.first(where: { $0.exerciseName == exerciseName }) {
                var impulse = 0.0
                exercise.sets.forEach {impulse = impulse + ($0.weight ?? 0) * ($0.reps  ?? 0)}
                return (workout.date, impulse)
            }
            return nil
        }
        //.sorted passes two args into closure and compares which one to put before the other. .date is needed to specify I am wanting to compare the date params of the tuple (not the names).
        .sorted { $0.date < $1.date } // chronological order
    }
}


extension workout_data {
    var asJSONSafe: WorkoutJSON {
        WorkoutJSON(
            id: id ?? UUID().uuidString,
            name: name,
            date: date,
            exercises: exercises,
            notes: notes
        )
    }
}

struct WorkoutJSON: Codable, Identifiable {
    var id: String
    var name: String
    var date: Date
    var exercises: [exercise_data]
    var notes: String?
}

struct chart_data_point: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

class logged_in_bool: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var isLoggedIn: Bool = false

    init() {
        // This runs once when you create an instance
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
}
