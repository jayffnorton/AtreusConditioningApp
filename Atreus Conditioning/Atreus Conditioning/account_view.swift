//
//  AccountView.swift
//  test
//
//  Created by Jay Norton on 20/09/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import WebKit

struct account_view: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    
    
    var body: some View { //If logged in show user account, otherwise show login page
        if loggedInBool.isLoggedIn {
            logged_in_view().environmentObject(loggedInBool)
        }
        else{
            login_view().environmentObject(loggedInBool)
        }
    }
}

struct logged_in_view: View{
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var loggedInBool: logged_in_bool
    
    var body: some View{
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()          // allow scaling
                .scaledToFit()        // maintain aspect ratio
                .frame(width: 100, height: 100) // adjust size
                .padding(.bottom, 100)
                .padding(.top, 20)
            
            GIFView(gifName: "what-huh")
            
            Text(UUID().uuidString)
                .padding(.bottom, 100)
            
            Button("Logout") {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }

                loggedInBool.isLoggedIn = false
            }
        }
        .padding()
    }
}

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
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AtreusIconInverted")
                .resizable()          // allow scaling
                .scaledToFit()        // maintain aspect ratio
                .frame(width: 100, height: 100) // adjust size
                .padding(.bottom, 50)
            
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
            
            Button("Login") {
                Auth.auth().signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Login failed: \(error.localizedDescription)")
                    } else if let user = result?.user {
                        print("Logged in as: \(user.email ?? "")")
                        loggedInBool.isLoggedIn = true
                    }
                }
            }
            
            Button("Sign Up") {
                Auth.auth().createUser(withEmail: email, password: password) {result, error in
                    if let error = error {
                        print("Error creating user: \(error.localizedDescription)")
                    } else if let user = result?.user {
                        print("User created: \(user.uid)")
                        loggedInBool.isLoggedIn = true
                        
                        // store extra profile data in Firestore
                        let db = Firestore.firestore()
                        db.collection("users").document(user.uid).setData([
                            "email": email,
                            "name": "New User",
                            "createdAt": FieldValue.serverTimestamp()
                        ]) { err in
                            if let err = err {
                                print("Error saving user data: \(err)")
                            } else {
                                print("User data saved to Firestore")
                            }
                        }
                    }
                }
                
            }
        }
        .padding()
    }
}


class logged_in_bool: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var isLoggedIn = false

    init() {
        // This runs once when you create an instance
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
}

struct UserProfile: Codable, Identifiable {
    var id: String      // unique user ID
    var name: String
    var email: String
    var avatarURL: String?  // optional profile image
}

class UserViewModel: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var currentUser: UserProfile? = nil
    @Published var isLoggedIn = false
    
    func login(email: String, password: String) {
        // Authenticate user, then:
        // self.currentUser = fetchedUser
        // self.isLoggedIn = true
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
    }
}

struct RootView: View {
    /*
     Property wrapper @EnvironmentObject shares an ObservableObject across
     it's children and itself. Automatically updates views according to
     @observedObject. Children don't need to be injected but do need
     the property wrapper declaration.
     */
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        if userVM.isLoggedIn {
            app_tabs() // your main app
        } else {
            login_view()
        }
    }
}


struct GIFView: UIViewRepresentable {
    let gifName: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        if let path = Bundle.main.path(forResource: gifName, ofType: "gif") {
            let data = try! Data(contentsOf: URL(fileURLWithPath: path))
            webView.load(
                data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: URL(fileURLWithPath: path)
            )
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

