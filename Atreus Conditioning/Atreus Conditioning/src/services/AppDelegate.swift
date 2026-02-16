//
//  AppDelegate.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 19/01/2026.
//


import UIKit
import Firebase
import FirebaseAuth

/*
 An AppDelegate is a special class recieves notifications about key events
 such as app launch, inactivity, notifs etc.
 */

class AppDelegate: NSObject, UIApplicationDelegate {

    /*
     Define application method, called by system early on with inputs being the app itself
     (suppressed when calling func by_) and a dictionary the system populates
     */
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        //Use firebase library to configure API's
        FirebaseApp.configure()
        return true
    }
}
