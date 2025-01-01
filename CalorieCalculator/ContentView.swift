//
//  ContentView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var loginModel: LoginModel
    @State private var selectedTab = 2  // Start with home tab selected
    
    var body: some View {
        if loginModel.loginSuccess {
            ZStack {
                // Main app background
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
                
                ZStack(alignment: .bottom) {
                    TabView(selection: $selectedTab) {
                        ProfileView()
                            .tag(0)
                        
                        DishView()
                            .tag(1)
                        
                        DashboardView()
                            .tag(2)
                        
                        LogView()
                            .tag(3)
                        
                        SettingsView()
                            .tag(4)
                    }
                    
                    EnhancedTabBar(selectedIndex: $selectedTab)
                        .padding(.bottom, 8)
                }
            }
        } else {
            LoginView()
        }
    }
}

struct EnhancedTabBar: View {
    @Binding var selectedIndex: Int
    @Namespace private var namespace
    
    private let tabs = [
        TabItem(icon: "person.fill", label: "Profile"),
        TabItem(icon: "fork.knife", label: "Dish"),
        TabItem(icon: "house.fill", label: "Home"),
        TabItem(icon: "list.bullet.clipboard.fill", label: "Log"),
        TabItem(icon: "gearshape.fill", label: "Settings")
    ]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    let isSelected = selectedIndex == index
                    
                    VStack(spacing: 4) {
                        // Icon with animated background
                        ZStack {
                            if isSelected {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [ModernColors.primary, ModernColors.accent]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .matchedGeometryEffect(id: "background", in: namespace)
                                    .frame(width: 45, height: 45)
                            }
                            
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: isSelected ? 20 : 18, weight: isSelected ? .bold : .regular))
                                .foregroundColor(isSelected ? .white : ModernColors.muted)
                                .frame(width: 45, height: 45)
                                .scaleEffect(isSelected ? 1.1 : 1.0)
                                .animation(.interpolatingSpring(stiffness: 300, damping: 15), value: isSelected)
                        }
                        
                        // Label with animation
                        Text(tabs[index].label)
                            .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                            .foregroundColor(isSelected ? ModernColors.primary : ModernColors.muted)
                            .opacity(isSelected ? 1 : 0.7)
                            .scaleEffect(isSelected ? 1.0 : 0.9)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8) // Reduced vertical padding
            .background(
                ZStack {
                    // Blurred background with reduced opacity
                    Color.black.opacity(0.6)
                        .blur(radius: 8)
                    
                    // Gradient overlay with reduced opacity
                    LinearGradient(
                        gradient: Gradient(colors: [
                            ModernColors.surface.opacity(0.7),
                            ModernColors.surface.opacity(0.5)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(ModernColors.surfaceHover.opacity(0.15), lineWidth: 0.5)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
            .shadow(color: ModernColors.primary.opacity(0.15), radius: 8, x: 0, y: 2)
            .padding(.horizontal)
        }
        .frame(height: 70) // Reduced overall height
    }
}

struct TabItem {
    let icon: String
    let label: String
}

#Preview {
    ContentView()
        .environmentObject(LoginModel())
}
