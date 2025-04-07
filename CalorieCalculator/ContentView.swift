//
//  ContentView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginModel: LoginModel
    @State private var selectedTab = 2
    @State private var showDailyGoalsSetup = false
    
    var body: some View {
        if loginModel.loginSuccess {
            ZStack {
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
                
                TabView(selection: $selectedTab) {
                    ProfileView().tag(0)
                    DishView().tag(1)
                    DashboardView().tag(2)
                    LogView().tag(3)
                    SettingsView().tag(4)
                }
                
                VStack {
                    Spacer()
                    FloatTabBar(selectedIndex: $selectedTab)
                        .padding(.bottom, -12)
                }
            }
            .onAppear {
                let setupComplete = UserDefaults.standard.bool(forKey: "isDailyGoalsSetupComplete")
                if !setupComplete {
                    showDailyGoalsSetup = true
                }
            }
            .fullScreenCover(isPresented: $showDailyGoalsSetup) {
                DailyGoalsSetupView()
                    .environmentObject(loginModel)
            }
        } else {
            LoginView()
        }
    }
}

struct FloatTabBar: View {
    @Binding var selectedIndex: Int
    @Namespace private var namespace
    
    private let tabs = [
        TabItem(icon: "person.fill", label: "Profile", color: ModernColors.accent),
        TabItem(icon: "fork.knife", label: "Dish", color: ModernColors.secondary),
        TabItem(icon: "house.fill", label: "Home", color: ModernColors.primary),
        TabItem(icon: "list.bullet.clipboard.fill", label: "Log", color: ModernColors.tertiary),
        TabItem(icon: "gearshape.fill", label: "Settings", color: ModernColors.highlight)
    ]
    
    private let hapticFeedback = UIImpactFeedbackGenerator(style: .soft)
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(0..<tabs.count, id: \.self) { index in
                FloatTabItem(
                    icon: tabs[index].icon,
                    label: tabs[index].label,
                    color: tabs[index].color,
                    isSelected: selectedIndex == index
                ) {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7, blendDuration: 0.2)) {
                        selectedIndex = index
                        hapticFeedback.impactOccurred()
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 20)
        .background(
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [ModernColors.surface, ModernColors.surfaceHover],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: ModernColors.neumorphicShadow.opacity(0.5), radius: 12, x: 0, y: 6)
        )
        .overlay(
            Capsule()
                .trim(from: 0.2, to: 0.8)
                .stroke(
                    LinearGradient(
                        colors: [ModernColors.shimmerOverlay, ModernColors.prismLight],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1
                )
                .opacity(0.6)
        )
    }
}

struct FloatTabItem: View {
    let icon: String
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    @State private var isHovering = false
    @State private var rotation: Double = 0
    @State private var pulse: CGFloat = 1.0
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(isSelected ? 0.3 : 0), color.opacity(isSelected ? 0.1 : 0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 42, height: 42)
                        .scaleEffect(pulse)
                        .opacity(isSelected ? 0.8 : 0)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? color : ModernColors.muted)
                        .shadow(color: isSelected ? color.opacity(0.4) : .clear, radius: 2)
                        .rotationEffect(.degrees(isSelected ? rotation : 0))
                }
                
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? color : ModernColors.muted.opacity(0.8))
                    .opacity(isSelected ? 1.0 : 0.7)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isHovering ? 1.15 : (isSelected ? 1.1 : 1.0))
        .offset(y: isSelected ? -4 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .onChange(of: isSelected) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.6)) {
                    rotation = 360
                }
                withAnimation(.easeInOut(duration: 1.2)/*.repeatForever(autoreverses: true)*/) {
                    pulse = 1.2
                }
            } else {
                rotation = 0
                pulse = 1.0
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}

struct TabItem {
    let icon: String
    let label: String
    let color: Color
}

#Preview {
    ContentView()
        .environmentObject(LoginModel())
}
