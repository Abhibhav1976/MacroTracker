//
//  SignUpView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

struct SignUpView: View {
    @StateObject private var signUpModel = SignUpModel()
    @State private var username: String = ""
    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading = false
    
    // Animation states
    @State private var isAnimating = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        ModernColors.background,
                        ModernColors.surface,
                        ModernColors.background
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .overlay(
                    Circle()
                        .fill(ModernColors.accent.opacity(0.1))
                        .frame(width: 200, height: 200)
                        .blur(radius: 50)
                        .offset(x: isAnimating ? 100 : -100, y: -150)
                        .animation(
                            Animation.easeInOut(duration: 7)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                )
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header with animations
                        VStack(spacing: 16) {
                            Image(systemName: "person.badge.plus.fill")
                                .font(.system(size: 70))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [ModernColors.primary, ModernColors.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .offset(y: isAnimating ? -5 : 5)
                                .animation(
                                    Animation.easeInOut(duration: 2)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                            
                            Text("Create Account")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(ModernColors.text)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.3), value: isAnimating)
                        }
                        .padding(.top, 40)
                        
                        // Sign Up Form with staggered animations
                        VStack(spacing: 24) {
                            // Username Field
                            CustomInputField(
                                title: "Username",
                                icon: "person.fill",
                                text: $username,
                                isSecure: false,
                                autocapitalization: .never
                            )
                            .offset(x: isAnimating ? 0 : -200)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)
                            
                            // Display Name Field
                            CustomInputField(
                                title: "Display Name",
                                icon: "person.text.rectangle.fill",
                                text: $displayName,
                                isSecure: false,
                                autocapitalization: .words
                            )
                            .offset(x: isAnimating ? 0 : -200)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.25), value: isAnimating)
                            
                            // Email Field
                            CustomInputField(
                                title: "Email",
                                icon: "envelope.fill",
                                text: $email,
                                isSecure: false,
                                autocapitalization: .never
                            )
                            .offset(x: isAnimating ? 0 : -200)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
                            
                            // Password Field
                            CustomInputField(
                                title: "Password",
                                icon: "lock.fill",
                                text: $password,
                                isSecure: true
                            )
                            .offset(x: isAnimating ? 0 : -200)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                            
                            // Error Message
                            if let errorMessage = signUpModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(ColorPalette.error)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // Sign Up Button
                            Button(action: {
                                withAnimation(.spring()) {
                                    isLoading = true
                                }
                                
                                signUpModel.signup(username: username, displayName: displayName, email: email, password: password) { result in
                                    DispatchQueue.main.async {
                                        isLoading = false
                                    }
                                }
                            }) {
                                ZStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.2)
                                    } else {
                                        Text("Create Account")
                                            .font(.headline)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [ModernColors.primary, ModernColors.secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: ModernColors.primary.opacity(0.3), radius: 15, x: 0, y: 5)
                            }
                            .disabled(isLoading)
                            .offset(y: isAnimating ? 0 : 100)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                            
                            // Already have account link
                            NavigationLink("Already have an account? Log In", destination: LoginView())
                                .foregroundColor(ModernColors.accent)
                                .font(.subheadline)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.7), value: isAnimating)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $signUpModel.signUpSuccess) {
                VerifyEmailView(email: email)
            }
            .onAppear {
                withAnimation {
                    isAnimating = true
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
