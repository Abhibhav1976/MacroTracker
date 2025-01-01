//
//  ProfileView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 27/12/24.
//

import SwiftUI

// MARK: - Main View
struct ProfileView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject private var updateModel = UpdateModel()
    @State private var showingWeightSheet = false
    @State private var showingTargetWeightSheet = false
    @State private var showingAgeSheet = false
    @State private var showingGoalsSheet = false
    @State private var isRefreshing = false
    @State private var refreshRotation = 0.0
    @State private var selectedTab = 0
    @Namespace private var animation
    
    private let username = UserDefaults.standard.string(forKey: "username") ?? "No username"
    
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
                VStack(spacing: 32) {
                    profileHeader
                    goalsSection
                    statsSection
                }
                .padding()
            }
            .refreshable {
                await refreshProfile()
            }
            
            if isRefreshing {
                loadingOverlay
            }
        }
        .onChange(of: updateModel.updateSuccess) { success in
            if success {
                Task {
                    await refreshProfile()
                }
            }
        }
        .sheet(isPresented: $showingWeightSheet) {
            UpdateWeightView(updateModel: updateModel, isPresented: $showingWeightSheet)
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $showingTargetWeightSheet) {
            UpdateTargetWeightView(updateModel: updateModel, isPresented: $showingTargetWeightSheet)
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $showingAgeSheet) {
            UpdateAgeView(updateModel: updateModel, isPresented: $showingAgeSheet)
                .transition(.move(edge: .bottom))
        }
        .sheet(isPresented: $showingGoalsSheet) {
            UpdateGoalsView(updateModel: updateModel, isPresented: $showingGoalsSheet)
                .transition(.move(edge: .bottom))
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [ModernColors.primary, ModernColors.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: ModernColors.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ModernColors.white)
            }
            .overlay(
                Circle()
                    .stroke(ModernColors.white.opacity(0.2), lineWidth: 4)
                    .blur(radius: 4)
            )
            
            VStack(spacing: 8) {
                Text(username)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(ModernColors.text)
                
                Text("Premium Member")
                    .font(.system(size: 16))
                    .foregroundColor(ModernColors.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(ModernColors.primary.opacity(0.1))
                    )
            }
        }
        .padding(.vertical, 16)
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 24))
                    .foregroundColor(ModernColors.accent)
                
                Text("Your Stats")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ModernColors.text)
            }
            
            GridLayout(columns: 2, spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingWeightSheet = true
                    }
                } label: {
                    StatItem(
                        title: "Current Weight",
                        value: "\(loginModel.userResponse?.currentWeight ?? 0) kg",
                        icon: "scalemass.fill"
                    )
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingTargetWeightSheet = true
                    }
                } label: {
                    StatItem(
                        title: "Target Weight",
                        value: "\(loginModel.userResponse?.targetWeight ?? 0) kg",
                        icon: "target"
                    )
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showingAgeSheet = true
                    }
                } label: {
                    StatItem(
                        title: "Age",
                        value: "\(loginModel.userResponse?.age ?? 0)",
                        icon: "heart.fill"
                    )
                }
                
                StatItem(
                    title: "Height",
                    value: "\(loginModel.userResponse?.height ?? 0) cm",
                    icon: "ruler.fill"
                )
            }
        }
    }
        
    
    private var goalsSection: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showingGoalsSheet = true
            }
        } label: {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "flag.fill")
                        .font(.system(size: 24))
                        .foregroundColor(ModernColors.primary)
                    
                    Text("Daily Goals")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(ModernColors.text)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(ModernColors.muted)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                VStack(spacing: 16) {
                    goalRow(
                        icon: "flame.fill",
                        title: "Calories",
                        value: "\(loginModel.userResponse?.requiredCalories ?? 0)",
                        unit: "kcal",
                        progress: 0.7,
                        color: ModernColors.tertiary
                    )
                    
                    goalRow(
                        icon: "p.circle.fill",
                        title: "Protein",
                        value: "150",
                        unit: "g",
                        progress: 0.6,
                        color: ModernColors.secondary
                    )
                    
                    goalRow(
                        icon: "leaf.fill",
                        title: "Carbs",
                        value: "200",
                        unit: "g",
                        progress: 0.4,
                        color: ModernColors.primary
                    )
                    
                    goalRow(
                        icon: "drop.fill",
                        title: "Fat",
                        value: "65",
                        unit: "g",
                        progress: 0.8,
                        color: ModernColors.quaternary
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(ModernColors.surface)
                    .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func goalRow(icon: String, title: String, value: String, unit: String, progress: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .foregroundColor(ModernColors.muted)
                
                Spacer()
                
                Text("\(value) \(unit)")
                    .foregroundColor(ModernColors.text)
                    .font(.system(size: 16, weight: .semibold))
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * progress)
                }
            }
            .frame(height: 8)
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .transition(.opacity)
            
            VStack(spacing: 16) {
                Circle()
                    .stroke(ModernColors.primary.opacity(0.3), lineWidth: 4)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(ModernColors.primary, lineWidth: 4)
                            .rotationEffect(Angle(degrees: refreshRotation))
                    )
                
                Text("Updating Profile...")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColors.text)
            }
            .transition(.scale.combined(with: .opacity))
        }
    }
    
    @MainActor
    private func refreshProfile() async {
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = true
        }
        
        withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
            refreshRotation = 360.0
        }
        
        let minimumLoadingTime = Task { try? await Task.sleep(nanoseconds: 800_000_000) }
        
        guard let username = UserDefaults.standard.string(forKey: "username"),
              let password = UserDefaults.standard.string(forKey: "password") else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isRefreshing = false
                refreshRotation = 0
            }
            return
        }
        
        await withCheckedContinuation { continuation in
            loginModel.login(username: username, password: password) { _ in
                continuation.resume()
            }
        }
        
        await minimumLoadingTime.value
        
        withAnimation(.easeInOut(duration: 0.3)) {
            isRefreshing = false
            refreshRotation = 0
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(LoginModel())
}
