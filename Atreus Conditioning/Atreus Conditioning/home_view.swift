//
//  SentView.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct home_view: View {
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseWorkouts: get_workouts
    @ObservedObject var firebaseTemplates: get_templates
    @ObservedObject var firebaseActivities: get_activities
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    
    @State private var showingAddWorkout = false
    
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    
                    if showingAddWorkout {
                        //indicate showingAddWorkout is a binding by using $
                        collapsible_add_workout_view(firebaseActivities: firebaseActivities, showingAddWorkout: $showingAddWorkout) //would be better wrapping this in a list somehow
                    }
                    else {
                        Text("Training Index")
                            .padding(.top, 90)
                        metric_ring_view(trainingIndex:50)
                            .padding(.bottom, 50)
                        Text("Leaderboard")
                            .padding(.bottom, 20)
                        
                    }
                }
            }
            
            VStack {
                HStack {
                    Text("Home")
                        .font(.headline)
                        .padding(.leading, 30)
                    Spacer()
                    if !showingAddWorkout{
                        Button(action: { showingAddWorkout = true }) {
                            Label("", systemImage: "plus.circle")
                        }
                        .padding(.trailing, 30)
                    }
                }
                .padding(.top, 60)
                .padding(.bottom, 10)
                .background(.ultraThinMaterial)
                .shadow(radius: 2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .position(x: UIScreen.main.bounds.width / 2, y: 35) // header height / 2
        }
        .ignoresSafeArea(edges: .top)
    }
}


struct metric_ring_view: View {
    var trainingIndex: Int
    var lineWidth: CGFloat = 7
    var ringColor: Color = .blue
    
    var body: some View {
        ZStack {
            // Progress ring
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                
            // Number in the middle
            Text("\(Int(trainingIndex))")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(ringColor)
        }
        .frame(width: 150, height: 150)
    }
}


struct collapsible_add_workout_view: View {
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


struct exercise_view: View {
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
            
            // --- Sets list ---
            ForEach(exercise.sets.indices, id: \.self) { idx in
                set_view(currentSet: $exercise.sets[idx])
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

struct set_view: View {
    @Binding var currentSet: set_data
    @State private var showStopwatch: Bool = true
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false

    var body: some View {
        if showStopwatch {
            VStack(spacing: 10) {
                Text(timeString(from: elapsedTime))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                    .frame(minWidth: 120)
                
                HStack {
                    Button(isRunning ? "Stop Set" : "Start Set") {
                        if isRunning {
                            stop(); currentSet.durationSeconds = elapsedTime
                        } else {
                            start()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Reset") {
                        reset()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isRunning == true)
                }
            }
            .padding()
            
        } else{
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
        
    }
    func start() {
        startTime = Date()
        isRunning = true
        
        // Update every 0.1s
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        showStopwatch = false
    }
    
    func reset() {
        elapsedTime = 0
    }
    
    // MARK: - Formatting
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

struct set_stopwatch_view: View {
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text(timeString(from: elapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .frame(minWidth: 120)
            
            HStack {
                Button(isRunning ? "Stop Set" : "Start Set") {
                    if isRunning {
                        stop()
                    } else {
                        start()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    reset()
                }
                .buttonStyle(.bordered)
                .disabled(isRunning == true)
            }
        }
        .padding()
    }
    
    // MARK: - Timer Control
    func start() {
        startTime = Date()
        isRunning = true
        
        // Update every 0.1s
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        elapsedTime = 0
    }
    
    // MARK: - Formatting
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}
