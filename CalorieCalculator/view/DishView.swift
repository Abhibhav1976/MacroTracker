//
//  DishView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 27/12/24.
//  Search Performance Optimized by Grok 3 on 04/13/25.
//

import SwiftUI

// MARK: - Models
struct Dish: Identifiable {
    let id: UUID = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let isFavorite: Bool
    let lastEaten: Date?
}

// MARK: - View Models
class DishViewModel: ObservableObject {
    @Published var recentDishes: [Dish] = []
    @Published var searchText: String = ""
    @Published var filteredDishes: [Dish] = []
    @Published var favoriteDishes: [Dish] = []
    @Published var scannedFoods: [Dish] = []
    @Published var selectedTab: DishSection = .recent
    @Published var isLoading: Bool = false
    
    init() {
        // Sample data To be implemented later
        recentDishes = [
            Dish(name: "Grilled Chicken Salad", calories: 350, protein: 40, carbs: 10, fat: 18, isFavorite: true, lastEaten: Date()),
            Dish(name: "Protein Smoothie", calories: 280, protein: 30, carbs: 35, fat: 8, isFavorite: false, lastEaten: Date().addingTimeInterval(-86400))
        ]
        filteredDishes = recentDishes
        updateFavorites()
    }
    
    func updateFavorites() {
        favoriteDishes = recentDishes.filter { $0.isFavorite }
    }
    
    func filterDishes() {
        if searchText.isEmpty {
            filteredDishes = recentDishes
        } else {
            filteredDishes = recentDishes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func simulateLoading() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
        }
    }
}

// MARK: - Supporting Views
enum DishSection: String, CaseIterable {
    case recent = "Recent"
    case scanned = "Scanned"
    case saved = "Saved"
    
    var icon: String {
        switch self {
        case .recent: return "clock.fill"
        case .scanned: return "camera.fill"
        case .saved: return "star.fill"
        }
    }
}

// MARK: - Main View
struct DishView: View {
    @StateObject private var viewModel = DishViewModel()
    @State private var showingSearch = false
    @State private var showingScanner = false
    @State private var selectedCardID: UUID?
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
                    headerSection
                    quickActionsSection
                    sectionPicker
                    selectedSectionContent
                }
                .padding(.top, 16)
            }
        }
        .sheet(isPresented: $showingSearch) {
            FoodSearchView(isPresented: $showingSearch)
        }
        .sheet(isPresented: $showingScanner) {
            ScanFoodCameraView()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Dishes")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(ModernColors.text)
                    .matchedGeometryEffect(id: "title", in: animation)
                Spacer()
            }
            
            // Search Button
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    showingSearch = true
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ModernColors.muted)
                    Text("Search foods...")
                        .foregroundColor(ModernColors.muted)
                    Spacer()
                }
                .padding()
                .background(ModernColors.surface)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var quickActionsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                QuickActionButton(
                    title: "Scan Food",
                    icon: "camera.fill",
                    color: ModernColors.primary
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingScanner = true
                    }
                }
                
                QuickActionButton(
                    title: "Create Meal",
                    icon: "plus.circle.fill",
                    color: ModernColors.secondary
                ) {
                    // To be added
                }
                
                QuickActionButton(
                    title: "Import",
                    icon: "square.and.arrow.down.fill",
                    color: ModernColors.accent
                ) {
                   // To be added
                }
            }
            .padding(.horizontal, 24)
        }
    }
    
    private var sectionPicker: some View {
        HStack(spacing: 0) {
            ForEach(DishSection.allCases, id: \.self) { section in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        viewModel.selectedTab = section
                        viewModel.simulateLoading()
                    }
                }) {
                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: section.icon)
                                .font(.system(size: 14))
                            Text(section.rawValue)
                                .font(.system(size: 16, weight: viewModel.selectedTab == section ? .semibold : .regular))
                        }
                        .foregroundColor(viewModel.selectedTab == section ? ModernColors.text : ModernColors.muted)
                        
                        Rectangle()
                            .fill(viewModel.selectedTab == section ? ModernColors.primary : Color.clear)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "tab_\(section)", in: animation)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 24)
    }
    
    @ViewBuilder
    private var selectedSectionContent: some View {
        if viewModel.isLoading {
            LoadingView()
                .transition(.opacity)
        } else {
            switch viewModel.selectedTab {
            case .recent:
                recentSection
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .scanned:
                scannedSection
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            case .saved:
                savedSection
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
    }
    
    private var recentSection: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.recentDishes) { dish in
                EnhancedDishCard(dish: dish, isSelected: selectedCardID == dish.id) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedCardID = selectedCardID == dish.id ? nil : dish.id
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var scannedSection: some View {
        VStack(spacing: 16) {
            if viewModel.scannedFoods.isEmpty {
                EmptyStateView(
                    icon: "camera.viewfinder",
                    title: "No Scanned Foods",
                    message: "Scan your first food item to get started",
                    action: { showingScanner = true }
                )
            } else {
                ForEach(viewModel.scannedFoods) { dish in
                    EnhancedDishCard(dish: dish, isSelected: selectedCardID == dish.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCardID = selectedCardID == dish.id ? nil : dish.id
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    
    private var savedSection: some View {
        VStack(spacing: 16) {
            if viewModel.favoriteDishes.isEmpty {
                EmptyStateView(
                    icon: "star.fill",
                    title: "No Saved Meals",
                    message: "Save your favorite meals for quick access",
                    action: nil
                )
            } else {
                ForEach(viewModel.favoriteDishes) { dish in
                    EnhancedDishCard(dish: dish, isSelected: selectedCardID == dish.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedCardID = selectedCardID == dish.id ? nil : dish.id
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Supporting Views
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 14))
                    .foregroundColor(ModernColors.text)
            }
            .frame(width: 100, height: 80)
            .background(ModernColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
        }
    }
}

struct EnhancedDishCard: View {
    let dish: Dish
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dish.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ModernColors.text)
                    
                    if let lastEaten = dish.lastEaten {
                        Text("Last eaten \(lastEaten.formatted(.relative(presentation: .named)))")
                            .font(.system(size: 14))
                            .foregroundColor(ModernColors.muted)
                    }
                }
                
                Spacer()
                
                if dish.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(ModernColors.primary)
                }
            }
            
            if isSelected {
                HStack(spacing: 20) {
                    MacroView(icon: "flame.fill", value: Double(dish.calories), unit: "kcal", color: ModernColors.tertiary)
                    MacroView(icon: "p.circle.fill", value: dish.protein, unit: "g", color: ModernColors.secondary)
                    MacroView(icon: "leaf.fill", value: dish.carbs, unit: "g", color: ModernColors.primary)
                    MacroView(icon: "drop.fill", value: dish.fat, unit: "g", color: ModernColors.quaternary)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .background(ModernColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isHovered ? ModernColors.primary.opacity(0.3) : ModernColors.muted.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .onTapGesture(perform: action)
        .onHover { hovering in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
    }
}

struct MacroView: View {
    let icon: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(String(format: "%.1f", value))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ModernColors.text)
            Text(unit)
                .font(.system(size: 12))
                .foregroundColor(ModernColors.muted)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(ModernColors.muted)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ModernColors.text)
            
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
            
            if let action = action {
                Button(action: action) {
                    Text("Get Started")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ModernColors.text)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(ModernColors.primary)
                        .cornerRadius(8)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(ModernColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
        )
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .stroke(ModernColors.muted.opacity(0.3), lineWidth: 4)
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(ModernColors.primary, lineWidth: 4)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                )
            
            Text("Loading...")
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .onAppear {
            withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    DishView()
}
