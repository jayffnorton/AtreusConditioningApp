//
//  testApp.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//

// This is the "root script" as identified by @main which runs when the app opens
import SwiftUI
import Firebase
import FirebaseAuth

@main
struct root: App {
    //The body of this struct will be re-run if the following variables change
    @StateObject private var viewModel = WorkoutViewModel() //Instantiate class
    @StateObject var loggedInBool = logged_in_bool() //Instantiate class
    /*
     Property wrapper @State identifies a variable which will cause this
     view to re-render. Due to the way these variables are stored they
     should always be private. It's mutable meaning it cna be changed after being set.
     */
    @State private var showSplash = true
    
    
    //Tell the system to instantiate the AppDelegate class (AppDelegate.self is a type reference)
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate //Allocate instance to appDelegate
     
    
    //init(){FirebaseApp.configure()}
    
    var body: some Scene {
        WindowGroup {
            if showSplash { //Show splash view on startup for two seconds
                splash_view()
                    .onAppear {
                        // Hide splash after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else { //Enter the app
                if loggedInBool.isLoggedIn {
                    app_tabs().environmentObject(viewModel).environmentObject(loggedInBool)

                } else{
                    invite_code_view().environmentObject(loggedInBool)
                }
            }
        }
    }
}

