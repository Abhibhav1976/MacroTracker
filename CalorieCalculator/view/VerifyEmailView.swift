//
//  VerifyEmailView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 15/04/25.
//

import SwiftUI

struct VerifyEmailView: View {
    @StateObject private var model: VerifyOTPModel
    @Environment(\.dismiss) private var dismiss
    @State private var isAnimating = false
    
    init(email: String) {
        _model = StateObject(wrappedValue: VerifyOTPModel(email: email))
    }
    
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
                        // Header
                        VStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
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
                            
                            Text("Verify Your Email")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(ModernColors.text)
                                .opacity(isAnimating ? 1 : 0)
                                .animation(.easeIn(duration: 0.5).delay(0.3), value: isAnimating)
                        }
                        .padding(.top, 40)
                        
                        // OTP Form
                        VStack(spacing: 24) {
                            // OTP Field
                            CustomInputField(
                                title: "OTP",
                                icon: "number.circle.fill",
                                text: $model.otp,
                                isSecure: false
                            )
                            .onChange(of: model.otp) { newValue in
                                model.otp = newValue.filter { $0.isNumber }
                            }
                            .offset(x: isAnimating ? 0 : -200)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: isAnimating)
                            
                            // Error Message
                            if let errorMessage = model.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(ColorPalette.error)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .transition(.move(edge: .top).combined(with: .opacity))
                            }
                            
                            // Verify Button
                            Button(action: {
                                withAnimation(.spring()) {
                                    model.isLoading = true
                                }
                                model.verifyOTP { result in
                                    DispatchQueue.main.async {
                                        model.isLoading = false
                                    }
                                }
                            }) {
                                ZStack {
                                    if model.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(1.2)
                                    } else {
                                        Text("Verify OTP")
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
                            .disabled(model.isLoading)
                            .offset(y: isAnimating ? 0 : 100)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                        }
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationDestination(isPresented: $model.isVerified) {
                LoginView()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
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
    VerifyEmailView(email: "test@example.com")
}
