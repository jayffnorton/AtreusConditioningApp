//
//  MyWorkoutsView.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 26/09/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct my_workouts_view: View {
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    @ObservedObject var firebaseWorkouts: get_workouts
    @ObservedObject var firebaseTemplates: get_templates
    @ObservedObject var firebaseActivities: get_activities

    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var showingWorkoutDetails = false
    @State private var showingTemplateDetails = false
    @State private var showingAddWorkout = false
    @State private var showingAddTemplate = false
    @State private var showingAddActivity = false
    @State private var selectedWorkout: workout_data? = nil
    @State private var selectedTemplate: template_data? = nil
    @State private var selectedActivity: activity_data? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    // MARK: Templates
                    Section {
                        Text("My Templates").font(.headline)
                        Button(action: { showingAddTemplate = true }) {
                            Label("New Template", systemImage: "plus.circle")
                        }
                        if firebaseTemplates.templates.isEmpty {
                            Text("No template data available").foregroundColor(.gray)
                        } else {
                            ForEach(firebaseTemplates.templates) { template in
                                HStack {
                                    Text(template.name)
                                    Spacer()
                                    Text(template.date.formatted())
                                    Button("Details") { selectedTemplate = template }
                                }
                            }
                        }
                    }

                    // MARK: Workouts
                    Section {
                        Text("My Workouts").font(.headline)
                        Button(action: { showingAddWorkout = true }) {
                            Label("New Workout", systemImage: "plus.circle")
                        }
                        if firebaseWorkouts.workouts.isEmpty {
                            Text("No workout data available").foregroundColor(.gray)
                        } else {
                            ForEach(firebaseWorkouts.workouts) { workout in
                                HStack {
                                    Text(workout.name)
                                    Spacer()
                                    Text(workout.date.formatted())
                                    Button("Details") { selectedWorkout = workout }
                                }
                            }
                        }
                    }

                    // MARK: Activities
                    Section {
                        Text("My Activities").font(.headline)
                        Button(action: { showingAddActivity = true }) {
                            Label("New Activity", systemImage: "plus.circle")
                        }
                        if firebaseActivities.activities.isEmpty {
                            Text("No activity data available").foregroundColor(.gray)
                        } else {
                            ForEach(firebaseActivities.activities) { activity in
                                HStack {
                                    Text(activity.name)
                                    Spacer()
                                    Button("Details") { selectedActivity = activity }
                                }
                            }
                        }
                    }
                }
                .padding()
            }

            .navigationTitle("My Workouts")

            // Sheets
            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(template: template)
            }
            .sheet(item: $selectedWorkout) { workout in
                WorkoutDetailView(workout: workout)
            }
            .sheet(isPresented: $showingAddWorkout) {
                add_workout_view(firebaseActivities: firebaseActivities) // Replace with your real AddWorkoutView
            }
            .sheet(isPresented: $showingAddActivity) {
                add_activity_view()
            }

            // Load data
            .onAppear {
                firebaseWorkouts.fetchWorkouts()
                firebaseTemplates.fetchTemplates()
                firebaseActivities.fetchActivities()
            }
        }
    }
}

struct WorkoutDetailView: View {
    let workout: workout_data
    
    var body: some View {
        VStack(spacing: 12) {
            Text(workout.name).font(.title)
            Text(workout.date.formatted())
            if let notes = workout.notes {
                Text(notes)
            }
            List(workout.exercises) { exercise in
                VStack(alignment: .leading) {
                    Text(exercise.exerciseName).bold()
                    ForEach(exercise.sets) { set in
                        Text("kg: \((set.weight ?? 0)), Reps: \((set.reps ?? 0)), Duration: \((set.durationSeconds ?? 0)), RPE: \((set.rpe ?? 0))")
                    }
                }
            }
        }
        .padding()
    }
}

struct TemplateDetailView: View {
    let template: template_data
    
    var body: some View {
        VStack(spacing: 12) {
        }
        .padding()
    }
}
