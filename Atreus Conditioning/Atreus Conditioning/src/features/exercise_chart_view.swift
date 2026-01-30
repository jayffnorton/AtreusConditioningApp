//
//  exercise_chart_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts


struct exercise_chart_view: View {
    let selectedExercise: String
    /*
     Property wrapper @ObservedObject observes an external class and can
     red/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    
    @ObservedObject var firebaseWorkouts: get_workouts
    @State private var rangeMonths: Int = 1 //Declare variable with type and inital value (no further init needed)
    
    
    var body: some View {
        VStack {
            /*Text("Exercise Impulse")
                .font(.headline)
                .foregroundColor(.white)
             */
            
            if firebaseWorkouts.workouts.isEmpty {
                Text("No workout data available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                let impulseData = firebaseWorkouts.workouts.impulse_history(for: selectedExercise)
                
                HStack {
                    Button{
                    } label: {
                        Label( "calendar image", systemImage: "calendar")
                            .labelStyle(.iconOnly)
                    }
                    ForEach([1, 3, 6, 12], id: \.self) { months in
                        Button("\(months)mo") {rangeMonths = months}
                                //.labelStyle(.iconOnly)
                                .padding(10)
                                .font(.caption)
                                .background(rangeMonths == months ? Color.blue.opacity(0.3) : Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        
                    }
                }
                .padding(.horizontal)
                
                Chart {
                    ForEach(impulseData, id: \.date) { dataPoint in
                        LineMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Impulse", dataPoint.impulse)
                        )
                        PointMark(
                            x: .value("Date", dataPoint.date),
                            y: .value("Impulse", dataPoint.impulse)
                        )
                    }
                }
                .chartXAxisLabel("Time", alignment: .center)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 300)
            }
        }
        .padding()
        //Call fetchWorkouts() to pull the latest data from Firestore.
        .onAppear {
            firebaseWorkouts.fetchWorkouts()
        }
    }
}

// big ballz
