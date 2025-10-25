//
//  ContentView.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//
//This script defines the top level layout of the app

import SwiftUI

struct app_tabs: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var viewModel: WorkoutViewModel
    @EnvironmentObject var loggedInBool: logged_in_bool
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab){ //Create side by side tabs of different views
            Tab("Account", systemImage: "person.crop.circle.fill", value: 0) {
                account_view()
                    .environmentObject(loggedInBool)
            }
            .badge("!")
            
            Tab("Analytics", systemImage: "scribble", value: 1) { //Image("graph.2d")
                analytics_view(firebaseActivities: get_activities())
            }
            .badge(2)

            Tab("Home", systemImage: "house", value: 2) {
                home_view()
            }

            
            Tab("AddWorkout", systemImage: "plus", value: 3) {
                my_workouts_view(firebaseWorkouts: get_workouts(), firebaseTemplates: get_templates(), firebaseActivities: get_activities())
            }
            
            Tab("InjuryReporter", systemImage: "exclamationmark.triangle.fill", value: 4) {
                add_workout_view(firebaseActivities: get_activities())
            }
            
            Tab("Exporter", systemImage: "square.and.arrow.up", value: 5 ) {
                add_workout_view(firebaseActivities: get_activities())
            }
        }
        //the following ads a slight delay after swipes. Animation could be enhanced using zstack and .transition
        .environmentObject(loggedInBool)
        .animation(.easeInOut(duration: 0.5), value: selectedTab)
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        // swipe left → next tab
                        if selectedTab < 5 { selectedTab += 1 }
                    } else if value.translation.width > threshold {
                        // swipe right → previous tab
                        if selectedTab > 0 { selectedTab -= 1 }
                    }
                }
        )
        //Use .onChange(of: selectedTab) to trigger animations or haptic feedback.?
    }
}
