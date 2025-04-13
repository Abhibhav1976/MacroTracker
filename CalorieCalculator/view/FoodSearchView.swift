//
//  FoodSearchView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 29/12/24.
//  Search Performance Optimized by Grok 3 on 04/13/25.
//

import SwiftUI

struct FoodSearchView: View {
    @StateObject private var viewModel = FoodSearchViewModel()
    @Binding var isPresented: Bool
    let userId = UserDefaults.standard.integer(forKey: "UserId")
    @State private var selectedFood: FoodItem?
    @EnvironmentObject var macrosModel: Macros
    @FocusState private var isSearchFieldFocused: Bool // NEW: Focus state for TextField

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        ModernColors.background,
                        ModernColors.surface.opacity(0.8), // CHANGED: Lighter opacity for faster rendering
                        ModernColors.background
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    enhancedSearchBar
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    contentArea
                        .padding(.top, 12)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Food Search")
                        .font(.custom("Azeret Mono", size: 24).bold())
                        .dynamicTypeSize(.large...DynamicTypeSize.xxLarge)                        .foregroundColor(ModernColors.text)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    dismissButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    cancelButton // NEW: Cancel button for ongoing searches
                }
            }
            .onAppear {
                // NEW: Focus TextField after a short delay to ensure view is loaded
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isSearchFieldFocused = true
                }
            }
        }
    }

    private var enhancedSearchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16)) // CHANGED: Smaller icon for cleaner look
                .foregroundColor(ModernColors.muted)
            
            TextField("Search foods...", text: $viewModel.searchText)
                .font(.custom("Azeret Mono", size: 16)) // CHANGED: Consistent font
                .foregroundColor(ModernColors.text)
                .focused($isSearchFieldFocused)
                .submitLabel(.search) // NEW: Enable search on return key
            
            if !viewModel.searchText.isEmpty {
                Button(action: {
                    viewModel.searchText = ""
                    viewModel.cancelSearch() // NEW: Cancel ongoing search
                    isSearchFieldFocused = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(ModernColors.muted)
                }
                // CHANGED: Removed transition to reduce overhead
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(ModernColors.glassLight) // CHANGED: Glass effect for consistency with DashboardView
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ModernColors.neumorphicHighlight.opacity(0.2), lineWidth: 1)
                )
        )
        // CHANGED: Removed shadow for performance
        .onChange(of: viewModel.searchText) { _ in
            viewModel.performSearch()
        }
    }

    private var contentArea: some View {
        Group {
            if viewModel.isLoading {
                enhancedLoadingView
            } else if let error = viewModel.error {
                enhancedErrorView(error: error)
            } else if !viewModel.recentSearches.isEmpty && viewModel.searchText.isEmpty {
                recentSearchesView // NEW: Show recent searches when empty
            } else {
                enhancedFoodList
            }
        }
    }

    private var enhancedLoadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.1)
                .tint(ModernColors.primary)
            
            Text("Finding foods...")
                .font(.custom("Azeret Mono", size: 14)) // CHANGED: Consistent font
                .foregroundColor(ModernColors.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func enhancedErrorView(error: Error) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(ModernColors.error)
            
            Text("Something went wrong")
                .font(.custom("Azeret Mono", size: 16))
                .dynamicTypeSize(.small...DynamicTypeSize.large)
                .foregroundColor(ModernColors.text)
            
            Text(error.localizedDescription)
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.loadFoodData() // Wrap async call in Task
                }
            }) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.custom("Azeret Mono", size: 16))
                    .foregroundColor(ModernColors.text)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ModernColors.glassLight)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(24)
    }

    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Searches")
                .font(.custom("Azeret Mono", size: 16))
                .dynamicTypeSize(.small...DynamicTypeSize.large)
                .foregroundColor(ModernColors.text)
                .padding(.horizontal, 16)
            
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.recentSearches, id: \.self) { term in
                        Button(action: {
                            viewModel.searchText = term
                            viewModel.performSearch()
                            isSearchFieldFocused = true
                        }) {
                            HStack {
                                Image(systemName: "clock")
                                    .font(.system(size: 14))
                                    .foregroundColor(ModernColors.muted)
                                Text(term)
                                    .font(.custom("Azeret Mono", size: 14))
                                    .foregroundColor(ModernColors.text)
                                Spacer()
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(ModernColors.glassLight)
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var enhancedFoodList: some View {
        Group {
            if !viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.searchResults) { food in
                            Button(action: {
                                selectedFood = food
                            }) {
                                EnhancedFoodRowView(food: food)
                                    .transition(.opacity) // CHANGED: Simplified transition
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if !viewModel.searchResults.isEmpty && viewModel.hasMoreResults {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    viewModel.loadMoreResults()
                                }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(item: $selectedFood) { food in
            MacroDetailView(food: food, userId: userId)
                .environmentObject(macrosModel)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(ModernColors.muted)
            
            Text("No foods found")
                .font(.custom("Azeret Mono", size: 18).bold())
                .dynamicTypeSize(.medium...DynamicTypeSize.xLarge)
                .foregroundColor(ModernColors.text)
            
            Text("Try adjusting your search terms")
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var dismissButton: some View {
        Button(action: { isPresented = false }) {
            Image(systemName: "xmark")
                .font(.system(size: 14))
                .foregroundColor(ModernColors.muted)
                .padding(8)
                .background(ModernColors.glassLight)
                .clipShape(Circle())
        }
    }
    
    private var cancelButton: some View {
        Button(action: {
            viewModel.cancelSearch()
            isSearchFieldFocused = true
        }) {
            Text("Cancel")
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.primary)
                .padding(8)
                .background(ModernColors.glassLight)
                .cornerRadius(8)
        }
        .opacity(viewModel.isLoading ? 1 : 0) // NEW: Show only when loading
    }
}

struct EnhancedFoodRowView: View {
    let food: FoodItem
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                Text(food.displayName)
                    .font(.custom("Azeret Mono", size: 16))
                    .dynamicTypeSize(.small...DynamicTypeSize.large)
                    .foregroundColor(ModernColors.text)
                
                Spacer()
                
                Text("\(food.standardServing.macros.calories) kcal")
                    .font(.custom("Azeret Mono", size: 14))
                    .foregroundColor(ModernColors.primary)
            }
            
            // Serving Info
            Text("Per \(String(format: "%.2f", food.standardServing.amount)) \(food.standardServing.unit)")
                .font(.custom("Azeret Mono", size: 12))
                .foregroundColor(ModernColors.muted)
            
            // Macros Grid
            HStack(spacing: 12) {
                MacroLabel(
                    icon: "flame.fill",
                    value: String(format: "%.0f", Double(food.standardServing.macros.calories)),
                    unit: "kcal",
                    color: ModernColors.primary
                )
                
                MacroLabel(
                    icon: "p.circle.fill",
                    value: String(format: "%.1f", food.standardServing.macros.protein),
                    unit: "g",
                    color: ModernColors.secondary
                )
                
                MacroLabel(
                    icon: "leaf.fill",
                    value: String(format: "%.1f", food.standardServing.macros.carbs),
                    unit: "g",
                    color: ModernColors.success
                )
                
                MacroLabel(
                    icon: "drop.fill",
                    value: String(format: "%.1f", food.standardServing.macros.fat),
                    unit: "g",
                    color: ModernColors.error
                )
            }
            if let brand = food.brandName {
                Text(brand)
                    .font(.custom("Azeret Mono", size: 12))
                    .foregroundColor(ModernColors.muted)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(ModernColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(ModernColors.neumorphicHighlight.opacity(isHovered ? 0.3 : 0.1), lineWidth: 1)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

struct MacroLabel: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color)
            Text("\(value)\(unit)")
                .font(.custom("Azeret Mono", size: 12))
                .foregroundColor(ModernColors.muted)
        }
    }
}

struct MacroDetailView: View {
    let food: FoodItem
    let userId: Int
    @State private var showFoodLogging = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var macrosModel: Macros
    
    var body: some View {
        NavigationView {
            ZStack {
                ColorPalette.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Nutrition Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition Information")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Per \(food.standardServing.amount) \(food.standardServing.unit)")
                            .font(.system(size: 14))
                            .foregroundColor(ColorPalette.subtext)
                        
                        VStack(spacing: 16) {
                            MacroRow(title: "Calories", value: "\(food.standardServing.macros.calories)", unit: "kcal", icon: "flame.fill")
                            MacroRow(title: "Protein", value: String(format: "%.1f", food.standardServing.macros.protein), unit: "g", icon: "p.circle.fill")
                            MacroRow(title: "Carbs", value: String(format: "%.1f", food.standardServing.macros.carbs), unit: "g", icon: "leaf.fill")
                            MacroRow(title: "Fat", value: String(format: "%.1f", food.standardServing.macros.fat), unit: "g", icon: "drop.fill")
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(ModernColors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .shadow(color: Color.black.opacity(0.05), radius: 10)
                    
                    if let brand = food.brandName {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Brand Information")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(brand)
                                .font(.system(size: 16))
                                .foregroundColor(ColorPalette.subtext)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(ModernColors.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .shadow(color: Color.black.opacity(0.05), radius: 10)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showFoodLogging = true
                    }) {
                        Text("Add to Diary")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ColorPalette.primaryButton)
                            .cornerRadius(12)
                    }
                }
                .padding(24)
            }
            .navigationTitle(food.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ColorPalette.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ColorPalette.primaryButton)
                }
            }
        }
        .sheet(isPresented: $showFoodLogging) {
            FoodLoggingView(
                isPresented: $showFoodLogging,
                foodItem: food
            )
            .environmentObject(macrosModel)
        }
    }
}

struct MacroRow: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ModernColors.primary)
            
            Text(title)
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.text)
            
            Spacer()
            
            Text("\(value) \(unit)")
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.muted)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(ModernColors.glassDark)
        )
    }
}
