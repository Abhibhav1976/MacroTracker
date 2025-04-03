//
//  FoodSearchView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 29/12/24.
//

import SwiftUI

struct FoodSearchView: View {
    @StateObject private var viewModel = FoodSearchViewModel()
    @Binding var isPresented: Bool
    let userId = UserDefaults.standard.integer(forKey: "UserId")
    @State private var selectedFood: FoodItem?
    @EnvironmentObject var macrosModel: Macros

    var body: some View {
        NavigationView {
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

                VStack(spacing: 0) {
                    enhancedSearchBar
                        .padding(.top, 8)
                    
                    contentArea
                        .padding(.top, 16)
                }
            }
            .navigationTitle("Food Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Food Search")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(ModernColors.text)
                }
            }
            .navigationBarItems(
                leading: dismissButton,
                trailing: filterButton
            )
        }
    }

    private var enhancedSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(ModernColors.muted)
            
            TextField("Search foods...", text: $viewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .foregroundColor(ModernColors.text)
                .accentColor(ModernColors.primary)
                
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(ModernColors.muted)
                        .font(.system(size: 16))
                }
                .transition(.scale)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.searchText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ModernColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(ModernColors.muted.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 8)
        .padding(.horizontal)
        .onChange(of: viewModel.searchText) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.performSearch() // Trigger search again
            }
        }
    }

    private var contentArea: some View {
        Group {
            if viewModel.isLoading {
                enhancedLoadingView
            } else if let error = viewModel.error {
                enhancedErrorView(error: error)
            } else {
                enhancedFoodList
            }
        }
    }

    private var enhancedLoadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(ModernColors.primary)
            
            Text("Finding foods...")
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func enhancedErrorView(error: Error) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(ModernColors.error)
            
            Text("Oops! Something went wrong")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ModernColors.text)
            
            Text(error.localizedDescription)
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: viewModel.loadFoodData) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColors.text)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ModernColors.primary)
                            .shadow(color: ModernColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
            }
        }
        .padding()
    }

    private var enhancedFoodList: some View {
        Group {
            if !viewModel.searchText.isEmpty && viewModel.searchResults.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.searchResults) { food in
                            Button(action: {
                                selectedFood = food
                            }) {
                                EnhancedFoodRowView(food: food)
                                    .transition(.opacity.combined(with: .scale))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        if !viewModel.searchResults.isEmpty {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    viewModel.loadMoreResults()
                                }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .sheet(item: $selectedFood) { food in
            MacroDetailView(food: food, userId: userId)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(ModernColors.muted)
                .padding(.bottom, 8)
            
            Text("No foods found")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(ModernColors.text)
            
            Text("Try adjusting your search terms")
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var dismissButton: some View {
        Button(action: { isPresented = false }) {
            Image(systemName: "xmark")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(ModernColors.muted)
                .padding(8)
                .background(
                    Circle()
                        .fill(ModernColors.surface)
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                )
        }
    }
    
    private var filterButton: some View {
        Button(action: {}) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(ModernColors.primary)
                .padding(8)
                .background(
                    Circle()
                        .fill(ModernColors.surface)
                        .shadow(color: Color.black.opacity(0.1), radius: 4)
                )
        }
    }
}

struct EnhancedFoodRowView: View {
    let food: FoodItem
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(food.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(ModernColors.text)
                
                Spacer()
                
                Text("\(food.standardServing.macros.calories) kcal")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(ModernColors.primary)
            }
            
            // Serving Info
            Text("Per \(String(format: "%.2f", food.standardServing.amount)) \(food.standardServing.unit)")
                .font(.system(size: 14))
                .foregroundColor(ModernColors.muted)
            
            // Macros Grid
            HStack(spacing: 16) {
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
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.subtext)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ModernColors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ModernColors.muted.opacity(0.1), lineWidth: 1)
                )
        )
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
                .font(.system(size: 14))
                .foregroundColor(color)
            Text("\(value)\(unit)")
                .font(.system(size: 14))
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
        HStack(spacing: 12) {
            // Icon Container
            Image(systemName: icon)
                .foregroundColor(ModernColors.primary)
                .font(.system(size: 16))
            
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(ModernColors.text)
            
            Spacer()
            
            Text("\(value) \(unit)")
                .font(.system(size: 16))
                .foregroundColor(ModernColors.muted)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ModernColors.surface)
        )
    }
}
