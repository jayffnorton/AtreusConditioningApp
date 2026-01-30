//
//  create_account_func.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 30/01/2026.
//

import SwiftUI
import Firebase
import FirebaseAuth


func create_account_func(email: String, password: String, loggedInBool: logged_in_bool) async -> Bool{
    var loggedInBool = false
    
    do {
        let result = try await Auth.auth().createUser(withEmail: email,password: password)
        print("Account created:", result.user.email ?? "")
        loggedInBool = true

    } catch let error as NSError {
        let errorMessage = AuthErrorCode(rawValue: error.code)
        report_error(errorMessage: "Something went wrong")
    }
    
    return loggedInBool
}
