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
            logged_in_view(firebaseWorkouts: get_workouts()).environmentObject(loggedInBool)
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
    @State private var showingConfirmDelete = false
    @Environment(\.dismiss) var dismiss
    @State private var errorMessage: String?
    @ObservedObject var firebaseWorkouts: get_workouts
    @State private var jsonOutput: String = ""
    @State private var showingShareSheet = false
    @State private var exportURL: URL?
    
    var body: some View{
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()          // allow scaling
                .scaledToFit()        // maintain aspect ratio
                .frame(width: 100, height: 100) // adjust size
                .padding(.bottom, 100)
                .padding(.top, 20)
            
            Text(UUID().uuidString)
                .padding(.bottom, 100)
            
            Button {
                do {
                    try Auth.auth().signOut()
                } catch {
                    print("Error signing out: \(error.localizedDescription)")
                }

                loggedInBool.isLoggedIn = false
            } label: {
                Text("Sign out")
            }
            
            Button("Export Workouts as JSON") {
                exportWorkouts()
            }
            .buttonStyle(.borderedProminent)
            
            ScrollView {
                Text(jsonOutput)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                }

            if let exportURL = exportURL {
                ShareLink(item: exportURL, preview: SharePreview("workouts.json"))
            }
            
            Button(role: .destructive) {
                showingConfirmDelete = true
            } label: {
                Text("Delete Account")
                    .bold()
            }
            .confirmationDialog("Are you sure?",
                                isPresented: $showingConfirmDelete,
                                titleVisibility: .visible) {
                Button("Delete My Account", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .padding()
        .onAppear {
            firebaseWorkouts.fetchWorkouts()
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user is currently logged in."
            return
        }

        let userId = user.uid
        let db = Firestore.firestore()

        // Step 1: Delete Firestore data
        db.collection("users").document(userId).delete { error in
            if let error = error {
                errorMessage = "Error deleting user data: \(error.localizedDescription)"
                return
            }

            // Step 2: Delete Authentication account
            user.delete { error in
                if let error = error {
                    errorMessage = "Error deleting account: \(error.localizedDescription)"
                } else {
                    // Step 3: Optionally sign out and dismiss
                    try? Auth.auth().signOut()
                    dismiss()
                }
            }
        }
    }
    
    func exportWorkouts() {
            let workouts = firebaseWorkouts.workouts
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            encoder.dateEncodingStrategy = .iso8601

            do {
                let data = try encoder.encode(workouts.map{$0.asJSONSafe})
                jsonOutput = String(data: data, encoding: .utf8) ?? "Encoding failed"

                // Save to temporary file for sharing
                let url = FileManager.default.temporaryDirectory.appendingPathComponent("workouts.json")
                try data.write(to: url)
                exportURL = url
            } catch {
                jsonOutput = "Error encoding workouts: \(error.localizedDescription)"
            }
        }
}



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
        }
    }
    
    func load_privacy_policy() {
        if let fileURL = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "md"),
           let contents = try? String(contentsOf: fileURL, encoding: .utf8) {
            privacyPolicyText = contents
        }
    }
}
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


class logged_in_bool: ObservableObject {
    /*
    Property wrapper @Published is an observable that is
    observed by a view. It will cause the view to refresh when the property updates.
    Does not own the lifecycle (init, usage, deallocation) of the variable.
    Only used in classes.
    */
    @Published var isLoggedIn: Bool = false

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

struct Feedback: Codable {
    let message: String
}

func sendFeedback(_ text: String) {
    guard let url = URL(string: "https://yourserver.com/send-email") else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let feedback = Feedback(message: text)
    request.httpBody = try? JSONEncoder().encode(feedback)

    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error { print("Error: \(error)") }
        else { print("Feedback sent!") }
    }.resume()
}
