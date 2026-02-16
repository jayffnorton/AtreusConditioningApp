//
//  login_view.swift
//  Atreus Conditioning
//
//  Created by Jay Norton on 06/12/2025.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct login_or_create_view: View {
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
     should always be private. It's mutable meaning it can be changed after being set.
     */
    @State private var email = ""
    @State private var password = ""
    @State private var passwordCheck = ""
    @State private var showingResetPassword: Bool = false
    @State private var showingPrivacyPolicy: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingErrorAlert: Bool = false
    @State private var newUser: Bool = false
    @State private var hasConsented: Bool = false
    
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
            
            if newUser == true {
                SecureField("Confirm Password", text: $passwordCheck)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            
            if newUser == false {
                Button {
                    Task {
                        do {
                            
                            if let infoDict = Bundle.main.infoDictionary,
                               let apiKey = infoDict["API_KEY"] as? String {
                                print("Firebase API Key in use: \(apiKey)")
                            } else {
                                print("API key not found in plist")
                            }
                            //Try and sign user in
                            
                            //Funcs marked with "throws" must be called with try but this does not handle errors
                            //let result = try await Auth.auth().createUser(withEmail: email, password: password)
                            let result = try await Auth.auth().signIn(withEmail: email, password: password)
                            
                            
                            print("Logged in as:", result.user.email ?? "")
                            loggedInBool.isLoggedIn = true
                            password = ""
                            
                            
                        } catch let error as NSError {
                            /*
                             Firebase almost always defines errors as NSError type in objective-c as this is the language
                             it's written in. Firebase API exposes these as swift Errors, but these don't have guaranteed
                             properties. Therefore, it's necessary to cast to NSError, then use AuthErrorCode to map
                             the error code to an enum.
                             
                             NSError types can also provide userInfo and domain info
                             */
                            
                            //let code = AuthErrorCode(rawValue: error.code)
                            
                            loggedInBool.isLoggedIn = false
                            
                            
                            switch AuthErrorCode(rawValue: error.code) {
                                
                            case .userNotFound:
                                // Account does not exist → show privacy policy before account creation
                                showingPrivacyPolicy = true
                                
                            case .wrongPassword:
                                errorMessage = "Incorrect password"
                                showingErrorAlert = true
                                
                            case .invalidCredential:
                                errorMessage = "Incorrect password"
                                showingErrorAlert = true
                                
                            case .weakPassword:
                                errorMessage = "Weak passwo"
                                showingErrorAlert = true
                                
                            case .invalidEmail:
                                errorMessage = "Please enter a valid email address"
                                showingErrorAlert = true
                                
                            default:
                                errorMessage = "Something went wrong: " + String(error.code) + " .Please try again"
                                showingErrorAlert = true
                            }
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
                
                Button {
                        showingPrivacyPolicy = true
                        newUser = true
                        
                } label: {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Button {
                    showingResetPassword = true
                    //Clear email and password from memory
                    //email = ""
                    //password = ""
                } label: {
                    Text("Forgotten password?")
                    
                }
            } else if newUser == true{
                
                
                Button {
                     if email.count > 0 && password.count > 0 && hasConsented == true{
                         Task{
                             do {
                                 let result = try await Auth.auth().createUser(withEmail: email,password: password)
                                 print("Account created:", result.user.email ?? "")
                                 loggedInBool.isLoggedIn = true
                                 password = ""
                                 passwordCheck = ""

                             } catch let error as NSError {
                                 /*
                                  Firebase almost always defines errors as NSError type in objective-c as this is the language
                                  it's written in. Firebase API exposes these as swift Errors, but these don't have guaranteed
                                  properties. Therefore, it's necessary to cast to NSError, then use AuthErrorCode to map
                                  the error code to an enum.
                                  
                                  NSError types can also provide userInfo and domain info
                                  */
                                 
                                 //let code = AuthErrorCode(rawValue: error.code)
                                 
                                 loggedInBool.isLoggedIn = false
                                 
                                 
                                 switch AuthErrorCode(rawValue: error.code) {
                                     
                                 case .weakPassword:
                                     errorMessage = "Weak password"
                                     showingErrorAlert = true
                                     
                                 case .emailAlreadyInUse:
                                     // Email is already associated with an account
                                     // Show an appropriate message or prompt sign-in instead
                                     errorMessage = "Please enter a email address not already associsted with an account"
                                     showingErrorAlert = true
                                     
                                 case .invalidEmail:
                                     errorMessage = "Please enter a valid email address"
                                     showingErrorAlert = true
                                     
                                 default:
                                     errorMessage = "Something went wrong: " + String(error.code) + " .Please try again"
                                     showingErrorAlert = true
                                 }
                             }
                         }
                        
                    }
                } label: {
                    Text("Sign up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Button {
                    newUser = false
                } label: {
                    Text("Back to login")
                }
            }
            
            Spacer()
            
        }
        .padding()
        .sheet(isPresented: $showingResetPassword) {
            reset_password_view()
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            privacy_policy_view(showingPrivacyPolicy: $showingPrivacyPolicy, hasConsented: $hasConsented)
        }
        .alert("Error", isPresented: $showingErrorAlert, presenting: errorMessage) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }
}

