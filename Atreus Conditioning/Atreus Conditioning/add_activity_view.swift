//
//  add_activity_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 04/10/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore


struct add_activity_view: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @Environment(\.dismiss) var dismiss
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var name = ""
    @State private var activityClass = ""
    @State private var instructions = ""
    @State private var targetedMuscleGroups: [String] = []
    @State private var muscleGroupWeightings: [Int] = []
    @State private var isIso: Bool = false
    
    let muscleGroupOptions = ["Calfs", "Tibialis", "Quads", "Hamstrings", "Hip Flexors",
                            "Glutes", "Abs", "Obliques", "Chest", "Lower Back", "Lower Traps",
                            "Mid Traps", "Lats", "Biceps", "Triceps", "Wrist Extenders",
                            "Upper Traps", "Mid Delts", "Rear Delts", "Front Delts", "Supraspinatus",
                            "Infraspinatus", "Adductors", "Abductors"]
    
    let activityClasses = ["Weightlifting", "Rowing", "Running"]

    var body: some View {
        NavigationStack {
            Form {
                Section("General Info") {
                    TextField("Activity Name", text: $name)
                    Picker("Activity Class", selection: $activityClass) {
                        ForEach(activityClasses, id: \.self) { option in
                            Text(option)
                        }
                    }
                    if (activityClass == "Weightlifting"){
                        Toggle("Isometric", isOn: $isIso)
                    }
                    TextField("Instructions", text: $instructions)
                }

                Section("Targeted muscle groups") {
                    ForEach(targetedMuscleGroups.indices, id: \.self) { idx in
                        HStack {
                            Picker("Select muscle group", selection: $targetedMuscleGroups[idx]) {
                                ForEach(muscleGroupOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .padding(.vertical, 4)

                            TextField("Weighting",
                                      text: Binding(
                                        get: { String(muscleGroupWeightings[idx]) },
                                        set: { muscleGroupWeightings[idx] = Int($0) ?? 0 }
                                      )
                            )
                            .keyboardType(.numberPad)
                            .frame(width: 60)
                        }
                    }
                    .onDelete { indices in
                        targetedMuscleGroups.remove(atOffsets: indices)
                        muscleGroupWeightings.remove(atOffsets: indices)
                    }

                    Button(action: {
                        targetedMuscleGroups.append(muscleGroupOptions.first ?? "")
                        muscleGroupWeightings.append(0)
                    }) {
                        Label("Add Muscle Group", systemImage: "plus.circle")
                    }
                }

                Section {
                    Button("Create Activity") { createActivity() }
                }
            }
            .navigationTitle("Create Activity")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { EditButton() }
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }

    func createActivity() {
        guard let user = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }

        let activity = activity_data(
            name: name,
            activityClass: activityClass,
            instructions: instructions,
            targetedMuscleGroups: targetedMuscleGroups,
            muscleGroupWeightings: muscleGroupWeightings,
            isIso: isIso
        )

        let db = Firestore.firestore()
        do {
            try db.collection("users")
                  .document(user.uid)
                  .collection("activities")
                  .addDocument(from: activity)
            dismiss()
        } catch {
            print("Error saving workout: \(error)")
        }
    }
}
