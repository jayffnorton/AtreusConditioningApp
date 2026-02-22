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
    @State private var notes = ""
    @State private var exercises: [exercise_data] = []
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    private var workoutForJSON: workout_data_json {
        compileWorkoutForJSON()
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
            
            
            if showError == true {
                error_view(errorMessage: errorMessage)
            }
            

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
                    Label("Close Workout", systemImage: "minus.circle")
                }
            }
            // Save button
            Section {
                Button("Save Workout") { saveWorkout(); showingAddWorkout = false }
            }
            
            Section {
                Button("Delete Workout") { deleteWorkoutCache(); showingAddWorkout = false}
            }
            
        }
        .animation(.easeInOut, value: isExpanded) // smooth expand/collapse
        .onAppear {
            firebaseActivities.fetchActivities();
            let recoveredWorkout = recoverWorkout()
            name = recoveredWorkout.name
            date = recoveredWorkout.date
            notes = recoveredWorkout.notes
            exercises = recoveredWorkout.exercises
        }
        /*
         Use _ as placeholder for unused parameter and use "in"
         to seperate the closures parameter list from the body
        */
        .onChange(of: exercises) { _, _ in cacheWorkout()}
        .onChange(of: showError) {_, _ in
            Task{
                try await Task.sleep(for: .seconds(10))
                //showError = false
                errorMessage = ""
            }
        }
        .padding(.top, 90)
        
    }
        
    
    func compileWorkoutForSave() -> workout_data {
        
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
            errorMessage = "No valid exercises to save"
            //showError = true
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
        errorMessage = "Successfully compiled workout."
        print("Successfully compiled workout with name: " + String(compiledWorkout.name))
        //showError = true
        return compiledWorkout
    }
        
        func compileWorkoutForJSON() -> workout_data_json {
            /*
             Compile workout as nested arrays without Firebase DOcumentID
             type property. (otherwise, this is the same as compileForSave)
             */

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
                errorMessage = "No valid exercises to save"
                //showError = true
                return workout_data_json(
                    name: "",
                    date: Date(),
                    exercises: [],
                    notes: ""
                )
            }

        let compiledWorkout = workout_data_json(
            name: name.isEmpty ? "Untitled Workout" : name,
            date: date,
            exercises: filteredExercises,
            notes: notes
        )
        errorMessage = "Successfully compiled workout."
        print("Successfully compiled workout with name: " + String(compiledWorkout.name))
        //showError = true
        return compiledWorkout
        
    }
    
    // MARK: - Save Function
    func saveWorkout() {

        let workout = compileWorkoutForSave()
        
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
            deleteWorkoutCache()
        } catch {
            print("Error saving workout: \(error)")
            errorMessage = "Failed to save workout." 
            //showError = true
            
        }
    }
    
    func cacheWorkout() {
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workoutCache.json")
        
        print("Workout cahce url:", url)
        
        do {
            let exercises = workoutForJSON.exercises
            for e in exercises {
                for s in e.sets {
                    print("Caching set durationSeconds:", s.durationSeconds as Any)
                }
            }
            
            let data = try JSONEncoder().encode(workoutForJSON)
            try data.write(to: url, options: [.atomic, .completeFileProtection])
            print("Successfully cached workout.")
            
        } catch {
            print("Error encoding workout to json: ", error)
            errorMessage = "Failed to cache workout."
            //showError = true
            return
        }
    }
    
    func recoverWorkout() -> (name: String, date: Date, notes: String, exercises: [exercise_data]) {
        
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workoutCache.json")
        do {
            let data = try Data(contentsOf: url)
            let workout =  try JSONDecoder().decode(workout_data_json.self, from: data)
            let name = workout.name
            let date = workout.date
            let notes = workout.notes
            let exercises: [exercise_data] = workout.exercises
            
            for e in exercises {
                for s in e.sets {
                    print("Decoding set durationSeconds:", s.durationSeconds as Any)
                }
            }
            
            print("Successfully recovered workout.")
            
            return (name, date, notes, exercises)
            
            
        } catch {
            print("Error decoding workout from json: ", error)
            errorMessage = "Failed to recover workout."
            //showError = true
            // Return a default tuple
            let name = ""
            let date = Date()
            let notes = ""
            let exercises: [exercise_data] = []
            
            return (name, date, notes, exercises)
        }
    }
    
    func deleteWorkoutCache() {
        let url = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("workoutCache.json")
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
                print("Successfully deleted workout cache.")
            }
        } catch {
            print("Error deleting workout cache:", error)
        }
    }
}

