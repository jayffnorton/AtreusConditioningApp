//
//  stopwatch_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI

struct set_stopwatch_view: View {
    @State private var startTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var isRunning = false
    
    var body: some View {
        VStack(spacing: 10) {
            Text(timeString(from: elapsedTime))
                .font(.system(size: 40, weight: .bold, design: .monospaced))
                .frame(minWidth: 120)
            
            HStack {
                Button(isRunning ? "Stop Set" : "Start Set") {
                    if isRunning {
                        stop()
                    } else {
                        start()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Reset") {
                    reset()
                }
                .buttonStyle(.bordered)
                .disabled(isRunning == true)
            }
        }
        .padding()
    }
    
    // MARK: - Timer Control
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
