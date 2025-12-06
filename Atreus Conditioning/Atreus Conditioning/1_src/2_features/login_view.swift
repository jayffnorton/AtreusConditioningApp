//
//  login_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct login_view: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var email = ""
    @State private var password = ""
    @State private var showingResetPassword: Bool = false
    @State private var showingPrivacyPolicy: Bool = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AtreusIconInverted")
                .resizable()          // allow scaling
                .scaledToFit()        // maintain aspect ratio
                .frame(width: 100, height: 100) // adjust size
                .padding(.bottom, 50)
                .padding(.top, 100)
            
            TextField("Email", text: $email)
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Login failed: \(error.localizedDescription)")
                    } else if let user = result?.user {
                        print("Logged in as: \(user.email ?? "")")
                        loggedInBool.isLoggedIn = true
                    }
                }
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Button("Sign Up") {
                showingPrivacyPolicy = true
            }
            
            Button {
                showingResetPassword = true
            } label: {
                Text("Forgotten password?")
                    
            }
            
            Spacer()
            
        }
        .padding()
        .sheet(isPresented: $showingResetPassword) {
            reset_password_view()// Replace with your real AddWorkoutView
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            privacy_policy_view(email: email, password: password).environmentObject(loggedInBool)
        }
    }
}
