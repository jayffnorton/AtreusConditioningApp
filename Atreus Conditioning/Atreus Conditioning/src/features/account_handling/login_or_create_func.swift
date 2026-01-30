//
//  login_or_create_account.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 30/01/2026.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseAuth

//Marked with "async" to allow swift UI to continue operating whilst waiting for a response from firestore.
//Likely should be contained within a Task{}

func login_or_create_func(email: String, password: String, loggedInBool: logged_in_bool) async -> Bool{
    /*
    Create or log into an account
    */
    
    //Do some code that involves trying a function call
    
    var showingPrivacyPolicy: Bool = false
    do {
        //Funcs marked with "throws" must be called with try but this does not handle errors
        let result = try await Auth.auth().signIn(withEmail: email, password: password)

        print("Logged in as:", result.user.email ?? "")
        loggedInBool.isLoggedIn = true

    } catch let error as NSError {
        /*
        Firebase almost always defines errors as NSError type in objective-c as this is the language
        it's written in. Firebase API exposes these as swift Errors, but these don't have guaranteed
         properties. Therefore, it's necessary to cast to NSError, then use AuthErrorCode to map
        the error code to an enum.
        
        NSError types can also provide userInfo and domain info
        */

        switch AuthErrorCode(rawValue: error.code) {

        case .userNotFound:
            // Account does not exist → show privacy policy before creation
            showingPrivacyPolicy = true

        case .wrongPassword:
            report_error(errorMessage: "Incorrect password")
            showingPrivacyPolicy = false

        case .invalidEmail:
            report_error(errorMessage: "Please enter a valid email address")
            showingPrivacyPolicy = false

        default:
            report_error(errorMessage: "Something went wrong. Please try again.")
            showingPrivacyPolicy = false
        }
    }
    
    return showingPrivacyPolicy
}
