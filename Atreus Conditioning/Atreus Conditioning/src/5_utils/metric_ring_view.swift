//
//  metric_ring_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Charts

struct metric_ring_view: View {
    var trainingIndex: Int
    var lineWidth: CGFloat = 7
    var ringColor: Color = .blue
    
    var body: some View {
        ZStack {
            // Progress ring
            Circle()
                .trim(from: 0.0, to: 0.5)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                
            // Number in the middle
            Text("\(Int(trainingIndex))")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(ringColor)
        }
        .frame(width: 150, height: 150)
    }
}
