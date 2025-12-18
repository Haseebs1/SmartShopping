//
//  SignUpView.swift
//  SmartShopping
//
//  Created by user279038 on 12/1/25.
//


import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var showPasswordError = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 5) {
                        Text("Create Account")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Join Smart Shopping today")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 30)
                    
                    // Form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name (optional)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            TextField("Enter your name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.words)
                                .focused($focusedField, equals: .name)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .email
                                }
                        }
                        
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
                            
                            SecureField("Create a password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .password)
                                .submitLabel(.next)
                                .onSubmit {
                                    focusedField = .confirmPassword
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .focused($focusedField, equals: .confirmPassword)
                                .submitLabel(.go)
                                .onSubmit {
                                    signUp()
                                }
                            
                            if showPasswordError {
                                Text("Passwords do not match")
                                    .foregroundColor(.red)
                                    .font(.caption2)
                                    .padding(.top, 2)
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
                    
                    // Sign Up Button
                    Button(action: signUp) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Create Account")
                                .frame(maxWidth: .infinity)
                                .fontWeight(.semibold)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .padding(.horizontal, 30)
                    .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
                    
                    Spacer(minLength: 50)
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    focusedField = .name
                }
            }
        }
    }
    
    private func signUp() {
        guard password == confirmPassword else {
            showPasswordError = true
            return
        }
        
        showPasswordError = false
        
        Task {
            let success = await authViewModel.signUp(
                email: email,
                password: password,
                name: name.isEmpty ? nil : name
            )
            
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    dismiss()
                }
            }
        }
    }
}

struct ResetPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                
                Text("Reset Password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal)
                    .focused($isEmailFocused)
                    .submitLabel(.go)
                    .onSubmit {
                        resetPassword()
                    }
                
                if let error = authViewModel.errorMessage {
                    Text(error)
                        .foregroundColor(error.contains("sent") ? .green : .red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button(action: resetPassword) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Send Reset Link")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(email.isEmpty || authViewModel.isLoading)
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isEmailFocused = true
                }
            }
        }
    }
    
    private func resetPassword() {
        Task {
            let success = await authViewModel.resetPassword(email: email)
            if success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    dismiss()
                }
            }
        }
    }
}
