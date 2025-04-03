//
//  LoginView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var loginModel: LoginModel
    @AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @State private var showingDashboard = false
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String? = nil

    // Animation states
    @State private var isAnimating = false
    @State private var isLoading = false

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

                VStack(spacing: 40) {
                    // Logo section with floating animation
                    VStack(spacing: 16) {
                        Image(systemName: "flame.fill")
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

                        Text("MacroTracker")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(ModernColors.text)
                            .opacity(isAnimating ? 1 : 0)
                            .animation(.easeIn(duration: 0.5).delay(0.3), value: isAnimating)
                    }
                    .padding(.top, 60)

                    // Login Form with staggered animations
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

                        // Password Field
                        CustomInputField(
                            title: "Password",
                            icon: "lock.fill",
                            text: $password,
                            isSecure: true
                            
                        )
                        .offset(x: isAnimating ? 0 : -200)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)

                        // Error Message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(ColorPalette.error)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // Login Button
                        Button(action: {
                            withAnimation(.spring()) {
                                isLoading = true
                            }

                            loginModel.login(username: username, password: password) { result in
                                DispatchQueue.main.async {
                                    isLoading = false
                                    switch result {
                                    case .success:
                                        loginModel.loginSuccess = true
                                        UserDefaults.standard.set(true, forKey: "isLoggedIn")
                                        if UserDefaults.standard.object(forKey: "isDailyGoalsSetupComplete") == nil {
                                            UserDefaults.standard.set(false, forKey: "isDailyGoalsSetupComplete")
                                        }
                                    case .failure(let error):
                                        withAnimation {
                                            errorMessage = error.localizedDescription
                                        }
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(1.2)
                                } else {
                                    Text("Login")
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
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Sign Up Link with fade animation
                    NavigationLink(destination: SignUpView()) {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(ModernColors.muted)
                            Text("Sign Up")
                                .foregroundColor(ModernColors.accent)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeIn(duration: 0.5).delay(0.5), value: isAnimating)
                    .padding(.bottom, 32)
                }
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
}

// Custom Input Field Component
struct CustomInputField: View {
    let title: String
    let icon: String
    @Binding var text: String
    let isSecure: Bool
    var autocapitalization: TextInputAutocapitalization = .sentences

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(ModernColors.muted)

            HStack {
                Image(systemName: icon)
                    .foregroundColor(isFocused ? ModernColors.accent : ModernColors.muted)
                    .animation(.easeInOut, value: isFocused)

                if isSecure {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(autocapitalization) // Apply autocapitalization
                } else {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .textInputAutocapitalization(autocapitalization) // Apply autocapitalization
                }
            }
            .foregroundColor(ModernColors.text)
            .padding()
            .background(ModernColors.surface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isFocused ? ModernColors.accent : ModernColors.muted.opacity(0.3),
                        lineWidth: 1
                    )
                    .animation(.easeInOut, value: isFocused)
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(LoginModel())
}
