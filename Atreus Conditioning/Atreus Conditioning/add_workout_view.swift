//
//  AddWorkoutView.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 19/09/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
// MARK: - AddWorkoutView

struct add_workout_view: View {
    @Environment(\.dismiss) var dismiss
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseActivities: get_activities
    
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var name = ""
    @State private var date = Date()
    @State private var exercises: [exercise_data] = []
    @State private var notes = ""

    var body: some View {
        List {
            // Workout info
            Section("Workout Info") {
                TextField("Workout Name", text: $name)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                TextField("Notes", text: $notes)
            }
            

            // Exercises
            ForEach(exercises.indices, id: \.self) { idx in
                exercise_view(firebaseActivities: firebaseActivities, exercise: $exercises[idx])
            }
            
            
            Section{
                Button(action: { exercises.append(exercise_data()) }) {
                    Label("Add Exercise", systemImage: "plus.circle")
                }
            }
            
            Section{
                EditButton()
            }

            // Save button
            Section {
                Button("Save Workout") { saveWorkout() }
            }
        }
        .onAppear {
                    firebaseActivities.fetchActivities() // fetch once here
                }
    }

    // MARK: - Save Function
    func saveWorkout() {
        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }

        // Filter out empty exercises or sets
        let filteredExercises = exercises.map { exercise -> exercise_data in
            let validSets = exercise.sets.filter { set in
                set.reps != nil ||
                set.durationSeconds != nil ||
                set.rpe != nil ||
                set.weight != nil
            }
            return exercise_data(id: exercise.id, exerciseName: exercise.exerciseName, sets: validSets)
        }.filter { !$0.exerciseName.isEmpty && !$0.sets.isEmpty }

        guard !filteredExercises.isEmpty else {
            print("No valid exercises to save")
            return
        }

        let workout = workout_data(
            name: name.isEmpty ? "Untitled Workout" : name,
            date: date,
            exercises: filteredExercises,
            notes: notes.isEmpty ? nil : notes
        )

        let db = Firestore.firestore()
        do {
            try db.collection("users")
                  .document(user.uid)
                  .collection("workouts")
                  .addDocument(from: workout)
            dismiss()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
}

// MARK: - Exercise View
