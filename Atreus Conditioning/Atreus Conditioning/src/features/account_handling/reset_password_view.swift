//
//  password_reset.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 30/01/2026.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import WebKit

struct reset_password_view: View {
    @State private var email = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Reset Password")
                .font(.largeTitle.bold())
                .padding(.top, 40)
                .padding(.bottom, 60)
            
            TextField("Enter your email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
                .padding(.bottom, 30)
                .focused($isEmailFocused)
            
            Button {
                resetPassword()
            } label: {
                Text("Send Reset Link")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            GIFView(gifName: "idiot-sandwich")
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Password Reset"),
                  message: Text(alertMessage),
                  dismissButton: .default(Text("OK")) {
                      alertMessage = ""
                  })
        }
        .onTapGesture {
            isEmailFocused = false
        }
    }
    
    private func resetPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = "Error: \(error.localizedDescription)"
            } else {
                alertMessage = "If an account exists for \(email), a reset link has been sent."
            }
            showAlert = true
        }
    }
}
