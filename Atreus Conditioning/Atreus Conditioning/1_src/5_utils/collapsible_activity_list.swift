//
//  collapsible_activity_list.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct CollapsibleActivityList: View {
    let activities: [activity_data]
    @Binding var trackedMetrics: Set<UUID>
    
    @State private var isExpanded = false // tracks collapsed/expanded state

    var body: some View {
        VStack(spacing: 10) {
            // Header: toggle to expand/collapse
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text("Tracked Metrics")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }

            // Collapsible list
            if isExpanded {
                ForEach(activities, id: \.id) { activity in
                    HStack {
                        Text(activity.name)
                        Spacer()
                        Image(systemName: trackedMetrics.contains(activity.id) ? "checkmark.square.fill" : "square")
                            .onTapGesture {
                                if trackedMetrics.contains(activity.id) {
                                    trackedMetrics.remove(activity.id)
                                } else {
                                    trackedMetrics.insert(activity.id)
                                }
                            }
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
                }
                .animation(.default, value: trackedMetrics) // smooth selection updates
            }
        }
        .animation(.easeInOut, value: isExpanded) // smooth expand/collapse
    }
}
