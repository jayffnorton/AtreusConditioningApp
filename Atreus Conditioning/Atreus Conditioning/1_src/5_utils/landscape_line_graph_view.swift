//
//  landscape_line_graph_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//


import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct landscape_line_graph_view: View {
    let dataPoints: [chart_data_point]
    let xLabel: String
    let yLabel: String
    let xRange: ClosedRange<Date>?
    let movingAverageWindow: Int = 5 // Number of points to average over
    
    // Compute moving average - does not take into account days on which no training is done
    private var movingAverageData: [chart_data_point] {
        guard !dataPoints.isEmpty else { return [] }
        var averages: [chart_data_point] = []

        for i in 0..<dataPoints.count {
            // determine the start of the window and handle initial values
            let startIndex = max(0, i - movingAverageWindow + 1)
            // slice dataPoints - window is a ArraySlice and points to the original array ΑΝD KEEPS THE ORIGINAL INDICES
            let window = dataPoints[startIndex...i]
            //
            let avgValue = window.map { $0.value }.reduce(0, +) / Double(window.count)
            averages.append(chart_data_point(date: dataPoints[i].date, value: avgValue))
        }

        return averages
    }
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
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
    }
}
