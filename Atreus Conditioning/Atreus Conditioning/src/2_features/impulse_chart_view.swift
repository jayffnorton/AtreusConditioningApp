//
//  impulse-CHART_VIEW.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct impulse_chart_view: View {
    /*
     Property wrapper @ObservedObject observes an external class and can
     read/react to. It does not control the class's lifecycle and updates
     the view when a change occurs.
     */
    
    @ObservedObject var firebaseWorkouts: get_workouts
    @StateObject private var orientation = OrientationInfo()
    
    @State private var rangeMonths: Int = 1 //Declare variable with type and inital value (no further init needed)
    @Environment(\.horizontalSizeClass) var hSizeClass
    var isLandscape: Bool {hSizeClass == .regular}
    
    let title: String
    
    var body: some View {
        VStack {
            
            //---Define graph title and x-axis range buttons ---
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
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
            
            //---Plot Graph---
            
            if firebaseWorkouts.workouts.isEmpty {
                Text("No workout data available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                
                // Declare an array of types chart_data_point
                var chartData: [chart_data_point] {
                    firebaseWorkouts.workouts.map { workout in
                        chart_data_point(date: workout.date, value: workout.totalReps)
                    }
                }
                
                //Declare a closed range of types Date
                var xAxisRange: ClosedRange<Date> {
                    let startDate = Calendar.current.date(byAdding: .month, value: -rangeMonths, to: Date()) ?? Date()
                    let endDate = Date()
                    return startDate...endDate
                }
                
                //---If in portrait mode, plot a simpler, smaller graph---
                if orientation.isLandscape {
                    HStack {
                        Text("Impulse")
                            .rotationEffect(.degrees(-90))
                            .font(.caption)
                        landscape_line_graph_view(dataPoints: chartData, xLabel: "Time", yLabel: "Impulse", xRange: xAxisRange)
                    }
                } else {
                    portrait_line_graph_view(dataPoints: chartData, xLabel: "Time", xRange: xAxisRange)
                }
            }
            //End of graph
        }
        //End of VStack
        .padding()
        //Call fetchWorkouts() to pull the latest data from Firestore.
        .onAppear {
            firebaseWorkouts.fetchWorkouts()
        }
    }
}
