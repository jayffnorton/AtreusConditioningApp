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

struct library_view: View {
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
    
    @State private var editingWorkout = false
    
    @State private var workoutStartDate = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
    @State private var workoutEndDate = Date()

    var filteredWorkouts: [workout_data] {
        firebaseWorkouts.workouts.filter {$0.date >= workoutStartDate && $0.date <= workoutEndDate}
    }
    
    var body: some View {
        
        if (editingWorkout == false) {
            //Don't think I can use List here due to multiple child views.
            ScrollView{
                VStack{
                    // MARK: Templates
                    VStack {
                        Text("My Templates").font(.headline)
                            .padding(.top, 7)
                        
                        Divider()
                        
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
                                .padding([.trailing, .leading], 5)
                                Divider()
                            }
                        }
                        
                        Button(action: { showingAddTemplate = true }) {
                            Label("New Template", systemImage: "plus.circle")
                        }
                        .padding([.top, .bottom], 7)
                    }
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 5)
                    .padding(.bottom, 7)
                    
                    
                    // MARK: Workouts
                    VStack {
                        Text("My Workouts").font(.headline)
                            .padding(.top, 7)
                        
                        DatePicker("From:", selection: $workoutStartDate, displayedComponents: .date)
                            .padding([.leading, .trailing], 7)
                        
                        DatePicker("To:", selection: $workoutEndDate, displayedComponents: .date)
                            .padding([.leading, .trailing, .bottom], 7)
                        Divider()
                        
                        if firebaseWorkouts.workouts.isEmpty {
                            Text("No workout data available").foregroundColor(.gray)
                        } else {
                            ForEach(filteredWorkouts) { workout in
                                VStack{
                                    HStack {
                                        Text(workout.name)
                                        Text(" - ")
                                        Text(workout.date.formatted(date: .numeric, time: .omitted))
                                        Spacer()
                                        Button(action: { selectedWorkout = workout; editingWorkout = true }) {
                                            Label("", systemImage: "magnifyingglass.circle")
                                        }
                                    }
                                    .padding([.trailing, .leading], 7)
                                    Divider()
                                    
                                }
                            }
                            
                            Button(action: { showingAddWorkout = true }) {
                                Label("New Workout", systemImage: "plus.circle")
                            }
                            .padding([.top, .bottom], 7)
                        }
                    }
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 5)
                    .padding(.bottom, 7)
                        
                    
                    // MARK: Activities
                    VStack {
                        Text("My Activities").font(.headline)
                            .padding(.top, 7)
                        
                        Button(action: { showingAddActivity = true }) {
                            Label("New Activity", systemImage: "plus.circle")
                        }
                        .padding([.top, .bottom], 7)
                        
                        Divider()
                        
                        if firebaseActivities.activities.isEmpty {
                            Text("No activity data available").foregroundColor(.gray)
                        } else {
                            ForEach(firebaseActivities.activities) { activity in
                                HStack {
                                    Text(activity.name)
                                    Spacer()
                                    Button("Details") { selectedActivity = activity }
                                }
                                .padding([.trailing, .leading], 5)
                                Divider()
                            }
                        }
                    }
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(12)
                    .padding([.leading, .trailing], 5)
                    .padding(.bottom, 5)
                }
            }
            .sheet(item: $selectedTemplate) { template in
                TemplateDetailView(template: template)
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
            
        } else{
            edit_workout_view(workout: selectedWorkout!, editingWorkout: $editingWorkout, firebaseActivities: firebaseActivities, firebaseWorkouts: firebaseWorkouts)
        }
        
        /*
        .sheet(item: $selectedWorkout) { workout in
            edit_workout_view(workout: workout, firebaseActivities: firebaseActivities, firebaseWorkouts: firebaseWorkouts)
        }
         */
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


