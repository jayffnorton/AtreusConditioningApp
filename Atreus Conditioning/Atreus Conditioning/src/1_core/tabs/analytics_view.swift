//
//  RecievedView.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct analytics_view: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    /*
     Property wrapper @StateObject owns an instance of an ObservablObject
     controlling its lifecycle so it can persist. Deallocated from memory
     if the view is not displayed.
     */
    @StateObject private var ownFirebaseWorkouts = get_workouts()
    @ObservedObject var firebaseActivities: get_activities
    @State private var trackedMetrics = Set<UUID>() //Set's are like arrays with unique elements, in this case it's a set of UUID's, initially empty
    
    var selectedActivities: [activity_data] {
        return firebaseActivities.activities.filter { trackedMetrics.contains($0.id) }
    }
    
    var body: some View {
        if loggedInBool.isLoggedIn {
            ScrollView{
                VStack {
                    Text("Analytics")
                        .padding(.bottom, 50)
                    impulse_chart_view(firebaseWorkouts: ownFirebaseWorkouts, title: "Total Impulse")
                        .padding(.bottom, 50)
                    Text("Tracked Metrics").padding(.bottom, 50)
                   
                    CollapsibleActivityList(activities: firebaseActivities.activities, trackedMetrics: $trackedMetrics)
                    
                    SelectedActivityCharts(activities: selectedActivities, firebaseWorkouts: ownFirebaseWorkouts)
                }
            }
            .onAppear {
                firebaseActivities.fetchActivities() // fetch once here
            }
            
        } else {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("Please login")
                        .foregroundColor(.white)
                        .font(.headline)
                    GIFView(gifName: "what-huh")
                }
            }
        }
    }
}

struct SelectedActivityCharts: View {
    let activities: [activity_data]
    @ObservedObject var firebaseWorkouts: get_workouts

    var body: some View {
        ForEach(Array(activities), id: \.id) { activity in
            activity_chart_view(firebaseWorkouts: firebaseWorkouts,
                                title: "\(activity.name) Load",
                                activity: activity.name)
        }
    }
}
