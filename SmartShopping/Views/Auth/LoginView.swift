//
//  LoginView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var showingResetPassword = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                            .padding(.top, 50)
                        
                        Text("Smart Shopping")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Your intelligent shopping companion")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 20)
                    
                    // Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .focused($focusedField, equals: .email)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .password
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .password)
                                .submitLabel(.go)
                                .onSubmit {
                                    login()
                                }
                        }
                        
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .padding(.top, 5)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    // Login Button
                    Button(action: login) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 30)
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                    
                    // Forgot Password
                    Button("Forgot Password?") {
                        showingResetPassword = true
                    }
                    .foregroundColor(.blue)
                    .font(.caption)
                    .padding(.top, 5)
                    
                    // Sign Up Section
                    VStack(spacing: 10) {
                        Divider()
                            .padding(.horizontal, 30)
                            .padding(.top, 20)
                        
                        Text("Don't have an account?")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button("Create Account") {
                            showingSignUp = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.regular)
                    }
                    .padding(.top, 10)
                    
                    Spacer(minLength: 50)
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingResetPassword) {
                ResetPasswordView()
                    .environmentObject(authViewModel)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .email
                }
            }
        }
    }
    
    private func login() {
        Task {
            _ = await authViewModel.signIn(email: email, password: password)
        }
    }
}
