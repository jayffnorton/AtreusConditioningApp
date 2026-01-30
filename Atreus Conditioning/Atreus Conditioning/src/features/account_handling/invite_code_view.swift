//
//  1_start_page.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct invite_code_view: View {
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
    @State private var inviteCode: String = ""
    @State private var isCodeValid = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            TextField("Invite Code", text: $inviteCode)
                .textInputAutocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            
            Button {
                if inviteCode == "12345678" {
                    withAnimation {
                        isCodeValid = true
                    }
                }
            } label: {
                Text("Enter")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .fullScreenCover(isPresented: $isCodeValid) {
            login_or_create_view().environmentObject(loggedInBool)
        }
    }
}
