//
//  get_workouts.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 26/09/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

class get_workouts: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var workouts: [workout_data] = []
    
    func fetchWorkouts() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(user.uid)
            .collection("workouts")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching workouts: \(error)")
                    return
                }
                self.workouts = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: workout_data.self)
                } ?? []
            }
    }
}

class get_templates: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var templates: [template_data] = []
    
    func fetchTemplates() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(user.uid)
            .collection("templates")
            .order(by: "date", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching templates: \(error)")
                    return
                }
                self.templates = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: template_data.self)
                } ?? []
            }
    }
}

class get_activities: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var activities: [activity_data] = []
    
    func fetchActivities() {
        guard let user = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(user.uid)
            .collection("activities")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching templates: \(error)")
                    return
                }
                self.activities = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: activity_data.self)
                } ?? []
            }
    }
}
