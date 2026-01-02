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

struct set_data: Identifiable, Codable {
    var id = UUID()
    var reps: Double?
    var weight: Double?
    var durationSeconds: TimeInterval?
    var rest: TimeInterval?
    var rpe: Double?
}

struct exercise_data: Identifiable, Codable {
    var id = UUID()
    var exerciseName: String = ""
    var sets: [set_data] = []
}

struct workout_data: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var date: Date
    var exercises: [exercise_data]
    var notes: String?
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

struct template_data: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var date: Date
    var exercises: [exercise_data]
    var notes: String?
}

struct activities_list: Codable, Identifiable {
    @DocumentID var id: String?
    var activities: [activity_data]
}

struct activity_data: Codable, Identifiable {
    var id = UUID()
    var name: String
    var activityClass: String
    var instructions: String
    var targetedMuscleGroups: [String]
    var muscleGroupWeightings: [Int]
    var isIso: Bool
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
