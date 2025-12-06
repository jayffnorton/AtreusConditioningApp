//
//  WorkoutModel.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 19/09/2025.
//

import SwiftUI

// Workout data model
struct Workout: Identifiable, Codable {
    let id: UUID
    var name: String
    var duration: Int // minutes
    var date: Date
}

// ViewModel with persistence
class WorkoutViewModel: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var workouts: [Workout] = [] {
        didSet { saveWorkouts() }
    }
    
    private let storageKey = "workout_data"
    
    init() {
        loadWorkouts()
    }
    
    func addWorkout(name: String, duration: Int, date: Date) {
        let newWorkout = Workout(id: UUID(), name: name, duration: duration, date: date)
        workouts.append(newWorkout)
    }
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadWorkouts() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            workouts = decoded
        }
    }
}
