//
//  SignUpView.swift
//  UpdatedApp
//
//  Created by Akhila Pasupunuri on 4/19/25.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var appState: AppState
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingSignIn = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.9, green: 0.95, blue: 1.0) // Light blue background
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Create Account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 40)
                    
                    TextField("Full Name", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .padding(.horizontal)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                        .padding(.horizontal)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.newPassword)
                        .padding(.horizontal)
                    
                    Button(action: {
                        if password != confirmPassword {
                            alertMessage = "Passwords do not match"
                            showingAlert = true
                            return
                        }
                        
                        if password.count < 6 {
                            alertMessage = "Password must be at least 6 characters long"
                            showingAlert = true
                            return
                        }
                        
                        if !email.contains("@") {
                            alertMessage = "Please enter a valid email address"
                            showingAlert = true
                            return
                        }
                        
                        if appState.authManager.signUp(name: name, email: email, password: password) {
                            appState.isLoggedIn = true
                        } else {
                            alertMessage = "Email already exists"
                            showingAlert = true
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .alert(isPresented: $showingAlert) {
                        Alert(
                            title: Text("Error"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Already have an account? Sign In")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}
 
