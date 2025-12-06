//
//  portrait_line_graph_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct portrait_line_graph_view: View {
    let dataPoints: [chart_data_point]
    let xLabel: String
    let xRange: ClosedRange<Date>?
    let movingAverageWindow: Int = 5 // Number of points to average

    // Compute moving average aligned with each data point
    private var movingAverageData: [chart_data_point] {
        guard !dataPoints.isEmpty else { return [] }
        var averages: [chart_data_point] = []

        for i in 0..<dataPoints.count {
            // Determine the window range: previous (window-1) points + current
            let startIndex = max(0, i - movingAverageWindow + 1)
            // Slice dataPoints, creating window, an ArraySlice which points to the original array AND INHERITS THE SAME INDICES
            let window = dataPoints[startIndex...i]
            // Map each array element to it's .value then sum starting from 0
            let avgValue = window.map { $0.value }.reduce(0, +) / Double(window.count)
            // Append chart data point instance
            averages.append(chart_data_point(date: dataPoints[i].date, value: avgValue))
            /*
             Another interesting way of doing this could be:
             
             let sum = (startIndex...i).reduce(0.0) { partialSum, index in
                 partialSum + dataPoints[index].value
             }
             let avgValue = sum / Double(i - startIndex + 1)
             
             where func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result
             
             so .reduce passes two args into the closure which returns the next partialSum
             */
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
