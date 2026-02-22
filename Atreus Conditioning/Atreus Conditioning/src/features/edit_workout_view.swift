//
//  edit_workout_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 09/11/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
// MARK: - AddWorkoutView

struct edit_workout_view: View {
    let workout: workout_data
    
    @Binding var editingWorkout: Bool 
    @Environment(\.dismiss) private var dismiss
    @State private var showConfirmDelete = false
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseActivities: get_activities
    @ObservedObject var firebaseWorkouts: get_workouts
    
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var name = ""
    @State private var date = Date()
    @State private var exercises: [exercise_data] = []
    @State private var notes = ""

    func get_params() {
        name = workout.name
        date = workout.date
        notes = workout.notes ?? ""
        exercises = workout.exercises
    }
    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                // Workout info
                VStack{
                    TextField("Workout Name", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Notes", text: $notes)
                }
                
                
                // Exercises
                ForEach(exercises.indices, id: \.self) { idx in
                    edit_exercise_view(firebaseActivities: firebaseActivities, exercise: $exercises[idx])
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
                    Button(action: { editingWorkout = false }) {
                        Label("Close Workout", systemImage: "minus.circle")
                    }
                }
                // Save button
                Section {
                    Button("Save Workout") { saveWorkout(); editingWorkout = false }
                    Button(role: .destructive) {
                        showConfirmDelete = true
                    } label: {
                        Label("Delete Workout", systemImage: "trash")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .confirmationDialog("Are you sure you want to delete this workout?",
                                        isPresented: $showConfirmDelete,
                                        titleVisibility: .visible) {
                        Button("Delete", role: .destructive) {
                            firebaseWorkouts.deleteWorkout(workout)
                            editingWorkout = false
                        }
                        Button("Cancel", role: .cancel) {}
                    }
                }
            }
        }
        //.animation(.easeInOut, value: isExpanded) // smooth expand/collapse
        .onAppear {firebaseActivities.fetchActivities();get_params()}
        .padding(.top, 90)
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
            id: workout.id, // keep the ID if we’re editing
            name: name.isEmpty ? "Untitled Workout" : name,
            date: date,
            exercises: filteredExercises,
            notes: notes.isEmpty ? nil : notes
        )

        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid).collection("workouts")

        do {
            if let workoutID = workout.id {
                // 🔹 UPDATE existing document
                try userRef.document(workoutID).setData(from: workout, merge: true)
                print("Workout updated successfully")
            } else {
                // 🔹 ADD new document
                try userRef.addDocument(from: workout)
                print("New workout saved successfully")
            }

            dismiss()
        } catch {
            print("Error saving workout: \(error)")
        }
    }

}

// MARK: - Exercise View

struct edit_exercise_view: View {
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseActivities: get_activities
    @Binding var exercise: exercise_data
    
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var showingActivityPicker = false
    
    @State private var showingAddActivity = false
    
    var body: some View {
        VStack{
            
            // --- Activity selector (opens sheet) ---
            VStack{
                Button {
                    showingActivityPicker = true
                } label: {
                    HStack {
                        Text(exercise.exerciseName.isEmpty ? "Select Activity" : exercise.exerciseName)
                            .foregroundColor(exercise.exerciseName.isEmpty ? .gray : .primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                }
                .padding([.leading, .trailing, .top], 5)
            }
            
            // --- Sets list ---
            ForEach(exercise.sets.indices, id: \.self) { idx in
                edit_set_view(currentSet: $exercise.sets[idx])
            }
            .onDelete { indices in
                exercise.sets.remove(atOffsets: indices)
            }
            
            // --- Add Set & Edit buttons ---
            
            Button(action: { exercise.sets.append(set_data()) }) {
                Label("Add Set", systemImage: "plus.circle")
            }
            
            EditButton()
                .padding(.bottom, 10)
        }
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
        .padding([.leading, .trailing], 5)
        .sheet(isPresented: $showingActivityPicker) {
            NavigationStack {
                Button(action: { showingActivityPicker = false; showingAddActivity = true }) {
                    Label("New Activity", systemImage: "plus.circle")
                }
                
                List(firebaseActivities.activities) { activity in
                    Button(activity.name) {
                        exercise.exerciseName = activity.name
                        showingActivityPicker = false
                    }
                }
                .navigationTitle("Select Activity")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .sheet(isPresented: $showingAddActivity) {
            add_activity_view()
        }
    }
}
// MARK: - Set View

struct edit_set_view: View {
    @Binding var currentSet: set_data
    @State private var showStopwatch: Bool = true
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false

    var body: some View {
        HStack(spacing: 12) {
            
            TextField("kg", text: Binding(
                get: {
                    if let w = currentSet.weight {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.weight = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
            
                      
            TextField("Reps", text: Binding(
                get: {
                    if let w = currentSet.reps {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.reps = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
            
            
            TextField("Duration", text: Binding(
                get: {
                    if let w = currentSet.durationSeconds {
                        return timeString(from: w)}
                    else {
                        return ""
                    }
                },
                set: {
                    let parts = $0.split(separator: ":").map(String.init)
                    if parts.count == 2,
                       let minutes = Double(parts[0]),
                       let seconds = Double(parts[1]) {
                        currentSet.durationSeconds = minutes * 60 + seconds
                    } else {
                        currentSet.durationSeconds = Double($0) ?? 0
                    }
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 90)
                    
            TextField("RPE", text: Binding(
                get: {
                    if let w = currentSet.rpe {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.rpe = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
        }
        .padding(.vertical, 4)
            
        }
    
    // MARK: - Formatting
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
