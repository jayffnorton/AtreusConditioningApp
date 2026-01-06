//
//  exercise_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

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
    @State private var showingActivityPicker: Bool = false
    @State private var showingAddActivity: Bool = false
    
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    
    @State private var newSet = set_data()
    
    @State private var resting: Bool = false
    
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
            
            Text(timeString(from: elapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .frame(minWidth: 120)
            
            if resting {
                HStack {
                    Button(isRunning ? "Stop Rest" : "Start Rest") {
                        if isRunning {
                            stop();
                            exercise.sets[-1].rest = elapsedTime;
                            resting = false;
                            elapsedTime = 0
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
                
            } else{
                HStack {
                    Button(isRunning ? "Stop Set" : "Start Set") {
                        if isRunning {
                            stop();
                            newSet.durationSeconds = elapsedTime;
                            exercise.sets.append(newSet);
                            resting = true;
                            elapsedTime = 0
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
                
                let activityList = firebaseActivities.activities.name.sorted()
                
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
