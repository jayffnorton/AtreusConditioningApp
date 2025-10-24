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
    
    var body: some View {
        if loggedInBool.isLoggedIn {
            ScrollView{
                VStack {
                    Text("Analytics")
                        .padding(.bottom, 50)
                    impulse_chart_view(firebaseWorkouts: ownFirebaseWorkouts)
                        .padding(.bottom, 50)
                    Text("Tracked Metrics").padding(.bottom, 50)
                    exercise_chart_view(selectedExercise: "Wall Sit", firebaseWorkouts: ownFirebaseWorkouts)
                    Text("Seated Hamstring Curl Iso Impulse").padding(.bottom, 50)
                    tracked_metrics_view()
                    exercise_chart_view(selectedExercise: "Seated Hamstring Curl Iso", firebaseWorkouts: ownFirebaseWorkouts)
                    Text("Single Leg Calf Raise Impulse").padding(.bottom, 50)
                    exercise_chart_view(selectedExercise: "Single Leg Calf Raise", firebaseWorkouts: ownFirebaseWorkouts)
                    Text("Bicep Curl Impulse").padding(.bottom, 50)
                    exercise_chart_view(selectedExercise: "Bicep Curl", firebaseWorkouts: ownFirebaseWorkouts)
                    Text("Tricep Extension Impulse").padding(.bottom, 50)
                    exercise_chart_view(selectedExercise: "Tricep Extension", firebaseWorkouts: ownFirebaseWorkouts)
                    Text("External Rotation Impulse").padding(.bottom, 50)
                    exercise_chart_view(selectedExercise: "External Rotation", firebaseWorkouts: ownFirebaseWorkouts)
                }
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
    
    var body: some View {
        VStack {
            
            //---Define graph title and x-axis range buttons ---
            Text("Total Impulse")
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

struct chart_data_point: Identifiable {
    var id = UUID()
    var date: Date
    var value: Double
}

struct portrait_line_graph_view_old: View {
    let dataPoints: [chart_data_point]
    let xLabel: String
    let xRange: ClosedRange<Date>?

    var body: some View {
        Chart {
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
            }
        }
        .chartXScale(domain: xRange!) //Force unwrap range, could cause issues
        .chartXAxisLabel(xLabel, alignment: .center)
        .chartYAxis(.hidden)
        .frame(height: 200)
    }
}

struct portrait_line_graph_view: View {
    let dataPoints: [chart_data_point]
    let xLabel: String
    let xRange: ClosedRange<Date>?
    let movingAverageWindow: Int = 3 // Number of points to average

    // Compute moving average aligned with each data point
    private var movingAverageData: [chart_data_point] {
        guard !dataPoints.isEmpty else { return [] }
        var averages: [chart_data_point] = []

        for i in 0..<dataPoints.count {
            // Determine the window range: previous (window-1) points + current
            let startIndex = max(0, i - movingAverageWindow + 1)
            let window = dataPoints[startIndex...i]
            let avgValue = window.map { $0.value }.reduce(0, +) / Double(window.count)
            averages.append(chart_data_point(date: dataPoints[i].date, value: avgValue))
        }

        return averages
    }

    var body: some View {
        Chart {
            // Original data points
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
            }
            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
            
            // Moving average line
            ForEach(movingAverageData) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Moving Average", point.value)
                )
                .foregroundStyle(.red.opacity(0.3))
            }
        }
        .chartXScale(domain: xRange!)
        .chartXAxisLabel(xLabel, alignment: .center)
        .chartYAxis(.hidden)
        .frame(height: 200)
    }
}

struct landscape_line_graph_view: View {
    let dataPoints: [chart_data_point]
    let xLabel: String
    let yLabel: String
    let xRange: ClosedRange<Date>?

    var body: some View {
        Chart {
            ForEach(dataPoints) { point in
                LineMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
                PointMark(
                    x: .value("Date", point.date),
                    y: .value("Value", point.value)
                )
            }
        }
        .chartXScale(domain: xRange!)
        .chartXAxisLabel(xLabel, alignment: .center)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
    }
}

class OrientationInfo: ObservableObject {
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    @objc func orientationChanged() {
        let orientation = UIDevice.current.orientation
        if orientation.isLandscape {
            isLandscape = true
        } else if orientation.isPortrait {
            isLandscape = false
        }
    }
}

struct tracked_metrics_view: View {
    
    var body: some View {
        VStack{
            
        }
    }
}

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


