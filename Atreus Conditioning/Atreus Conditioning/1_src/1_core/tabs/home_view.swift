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
                        add_workout_view(firebaseActivities: firebaseActivities, showingAddWorkout: $showingAddWorkout) //would be better wrapping this in a list somehow
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

