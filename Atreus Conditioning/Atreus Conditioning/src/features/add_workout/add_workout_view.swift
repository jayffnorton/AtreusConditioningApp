//
//  add_workout_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct add_workout_view: View {
    @Environment(\.dismiss) var dismiss
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseActivities: get_activities
    
    @Binding var showingAddWorkout: Bool
    
    @State private var isExpanded = false // tracks collapsed/expanded state
    
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var name = ""
    @State private var date = Date()
    @State private var exercises: [exercise_data] = []
    @State private var notes = ""
    
    private var workout: workout_data {
        compileWorkout()
    }
    
    
    var body: some View {
        VStack(spacing: 10) {
            // Workout info
            VStack {
                TextField("Workout Name", text: $name)
                    .padding([.top, .leading, .trailing],10)
                DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    .padding([.leading, .trailing],10)
                TextField("Notes", text: $notes)
                    .padding([.bottom, .leading, .trailing],10)
            }
            .background(Color.gray.opacity(0.3))
            .cornerRadius(12)
            .padding([.leading, .trailing], 5)
            
            

            // Exercises
            ForEach(exercises.indices, id: \.self) { idx in
                exercise_view(firebaseActivities: firebaseActivities, exercise: $exercises[idx])
            }
            
            
            Section{
                Button(action: { exercises.append(exercise_data()) }) {
                    Label("Add activity", systemImage: "plus.circle")
                }
            }
            
            Section{
                EditButton()
            }
            
            Section {
                Button(action: { showingAddWorkout = false }) {
                    Label("Cancel Workout", systemImage: "minus.circle")
                }
            }
            // Save button
            Section {
                Button("Save Workout") { saveWorkout(); showingAddWorkout = false }
            }
        }
        .animation(.easeInOut, value: isExpanded) // smooth expand/collapse
        .onAppear {firebaseActivities.fetchActivities()}
        /*
         Use _ as placeholder for unused parameter and use "in"
         to seperate the closures parameter list from the body
        */
        .onChange(of: exercises) { _, _ in cacheWorkout() }
        .padding(.top, 90)
        
    }
        
    
    func compileWorkout() -> workout_data {

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
            return workout_data(
                name: "",
                date: Date(),
                exercises: [],
                notes: nil
            )
        }

        let compiledWorkout = workout_data(
            name: name.isEmpty ? "Untitled Workout" : name,
            date: date,
            exercises: filteredExercises,
            notes: notes.isEmpty ? nil : notes
        )
        return compiledWorkout
    }
    
    // MARK: - Save Function
    func saveWorkout() {
        let workout = compileWorkout()

        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        
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
    
    func cacheWorkout() {

        let workout = compileWorkout()
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workoutCache.json")
        do {
            let data = try JSONEncoder().encode(workout)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Error encoding workout to json")
            return
        }
    }
    
    func recoverWorkout() -> workout_data {
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workoutCache.json")
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(workout_data.self, from: data)
        } catch {
            // Return an empty workout_data if loading or decoding fails
            return workout_data(
                name: "",
                date: Date(),
                exercises: [],
                notes: nil
            )
        }
    }
}

