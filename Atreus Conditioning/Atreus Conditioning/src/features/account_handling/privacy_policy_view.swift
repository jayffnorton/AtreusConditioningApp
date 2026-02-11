//
//  privacy_policy_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 30/01/2026.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import WebKit


struct privacy_policy_view: View {
    
    let email: String
    let password: String
    
    @EnvironmentObject var loggedInBool: logged_in_bool
    
    @State private var privacyPolicyText: String = ""
    
    var body: some View {
        ScrollView{
            VStack{
                ScrollView {
                    Text(privacyPolicyText)
                }
                .onAppear{load_privacy_policy()}
                .padding(.bottom, 60)
                
                Button("I consent to the privacy policy") {
                    Task{
                        do {
                            let result = try await Auth.auth().createUser(withEmail: email,password: password)
                            print("Account created:", result.user.email ?? "")
                            loggedInBool.isLoggedIn = true

                        } catch let error as NSError {
                            loggedInBool.isLoggedIn = false
                            
                            
                        }
                    }
                    
                }
            }
        }
    }
    
    func load_privacy_policy() {
        if let fileURL = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "md"),
           let contents = try? String(contentsOf: fileURL, encoding: .utf8) {
            privacyPolicyText = contents
        }
    }
}
