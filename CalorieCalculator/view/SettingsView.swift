//
//  SettingsView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 27/12/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject private var updateModel = UpdateModel()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @State private var notificationsEnabled = true
    @State private var selectedSection: String?
    @State private var showingLogoutAlert = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            // Background gradient
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    header
                        .padding(.top, 16)
                    
                    // Quick Stats
                    quickStats
                    
                    // Settings Sections
                    VStack(spacing: 16) {
                        SettingsSection(title: "Account", icon: "person.circle.fill", isSelected: selectedSection == "Account") {
                            selectedSection = selectedSection == "Account" ? nil : "Account"
                        } content: {
                            SettingsRow(icon: "envelope.fill", title: "Email", value: "user@example.com")
                            SettingsRow(icon: "bell.badge.fill", title: "Notifications", isToggle: true, toggleValue: $notificationsEnabled)
                            SettingsRow(icon: "moon.stars.fill", title: "Dark Mode", isToggle: true, toggleValue: $isDarkMode)
                        }
                        
                        SettingsSection(title: "Preferences", icon: "gearshape.circle.fill", isSelected: selectedSection == "Preferences") {
                            selectedSection = selectedSection == "Preferences" ? nil : "Preferences"
                        } content: {
                            SettingsRow(icon: "scalemass.fill", title: "Units", value: "Metric", action: {})
                            SettingsRow(icon: "calendar", title: "Start of Week", value: "Monday", action: {})
                        }
                        
                        SettingsSection(title: "Support", icon: "questionmark.circle.fill", isSelected: selectedSection == "Support") {
                            selectedSection = selectedSection == "Support" ? nil : "Support"
                        } content: {
                            SettingsRow(icon: "doc.fill", title: "Privacy Policy", showArrow: true, action: {})
                            SettingsRow(icon: "doc.text.fill", title: "Terms of Service", showArrow: true, action: {})
                            SettingsRow(icon: "envelope.circle.fill", title: "Contact Support", showArrow: true, action: {})
                        }
                    }
                    
                    // Logout Button
                    logoutButton
                }
                .padding(.horizontal, 24)
            }
        }
        .alert("Log Out", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                withAnimation {
                    loginModel.logout()
                }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Settings")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ModernColors.text)
                    .matchedGeometryEffect(id: "title", in: animation)
                
                Text("Customize your experience")
                    .font(.system(size: 16))
                    .foregroundColor(ModernColors.muted)
            }
            Spacer()
        }
    }
    
    private var quickStats: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "flame.fill",
                title: "Daily Goal",
                value: "\(loginModel.userResponse?.requiredCalories ?? 0)",
                unit: "kcal",
                color: ModernColors.tertiary
            )
            
            StatCard(
                icon: "figure.walk",
                title: "Activity",
                value: "\(loginModel.userResponse?.activityLevel ?? "Not Set")",
                color: ModernColors.secondary
            )
        }
    }
    
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack(spacing: 8) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out")
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [ModernColors.error, ModernColors.destructive]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: ModernColors.error.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(.vertical, 8)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    var unit: String?
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(ModernColors.muted)
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(ModernColors.text)
                
                if let unit = unit {
                    Text(unit)
                        .font(.system(size: 14))
                        .foregroundColor(ModernColors.muted)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(ModernColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .onTapGesture {
            withAnimation {
                isHovered.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isHovered = false
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
