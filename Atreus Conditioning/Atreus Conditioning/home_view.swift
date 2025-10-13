//
//  SentView.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//

import SwiftUI

struct home_view: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    var body: some View {
        NavigationStack{
            VStack{
                Text("Training Index")
                    .padding(.top, 20)
                metric_ring_view(trainingIndex:50)
                    .padding(.bottom, 50)
                Text("Leaderboard")
                    .padding(.bottom, 20)
                NavigationStack{
                    
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.automatic)
        }
        
        
    }
}

struct DetailView: View {
    var body: some View {
        Text("This is the detail screen")
            .navigationTitle("Details")
    }
}

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
