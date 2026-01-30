//
//  set_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Charts

struct set_view: View {
    @Binding var currentSet: set_data
    @State private var showStopwatch: Bool = true
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false

    var body: some View {
        HStack(spacing: 12) {
            TextField("kg", text: Binding(
                get: {
                    if let w = currentSet.weight {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.weight = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
                      
            TextField("Reps", text: Binding(
                get: {
                    if let w = currentSet.reps {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.reps = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
            
            TextField("Duration", text: Binding(
                get: {
                    if let w = currentSet.durationSeconds {
                        return timeString(from: w)}
                    else {
                        return ""
                    }
                },
                set: {
                    let parts = $0.split(separator: ":").map(String.init)
                    if parts.count == 2,
                       let minutes = Double(parts[0]),
                       let seconds = Double(parts[1]) {
                        currentSet.durationSeconds = minutes * 60 + seconds
                    } else {
                        currentSet.durationSeconds = Double($0) ?? 0
                    }
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 90)
                    
            TextField("RPE", text: Binding(
                get: {
                    if let w = currentSet.rpe {
                        return String(w)}
                    else {
                        return ""
                    }
                },
                set: {
                    currentSet.rpe = Double($0)
                }
            ))
                .keyboardType(.decimalPad)
                .frame(width: 60)
        }
        .padding(.vertical, 4)
        
        
    }
    
    func start() {
        startTime = Date()
        isRunning = true
        
        // Update every 0.1s
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            if let startTime = startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        showStopwatch = false
    }
    
    func reset() {
        elapsedTime = 0
    }
    
    // MARK: - Formatting
    func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        let milliseconds = Int((interval.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, milliseconds)
    }
}

