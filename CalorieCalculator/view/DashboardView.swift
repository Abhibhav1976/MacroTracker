//
//  DashboardView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject var macrosModel = Macros()
    @State private var showingQuickAdd = false
    @State private var showingScanner = false
    @State private var showingFoodInput = false
    @State private var showingFoodLogging = false
    @State private var scannedBarcode: String = ""
    @State private var fetchedFoodItem: BarcodeScannedFood?
    @State private var showingBarcodeFoodLogging = false
    @State private var errorMessage: String = ""
    @State private var showError = false
    
    // Animation states
    @State private var isAnimating = false
    
    private func currentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    var userResponse: UserResponse?
    private let username = UserDefaults.standard.string(forKey: "username") ?? "No username"
    private let userId = UserDefaults.standard.integer(forKey: "UserId")
    
    var body: some View {
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Text animation
                    Text("Welcome \(username)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ModernColors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : -20)
                        .animation(.easeOut(duration: 0.6), value: isAnimating)
                    
                    // Macro Summary Card
                    MacroSummaryCardDashboard(isAnimating: isAnimating)
                        .offset(y: isAnimating ? 0 : 50)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isAnimating)
                    
                    // Quick Action Buttons
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        QuickActionButtonDashboard(
                            title: "Quick Add",
                            icon: "plus",
                            color: ModernColors.primary
                        ) {
                            showingQuickAdd = true
                        }
                        .offset(y: isAnimating ? 0 : 100)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: isAnimating)
                        
                        QuickActionButtonDashboard(
                            title: "Scan Barcode",
                            icon: "camera.fill",
                            color: ModernColors.secondary
                        ) {
                            showingScanner = true
                        }
                        .offset(y: isAnimating ? 0 : 100)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isAnimating)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showingQuickAdd) {
            if userId != 0 {
                MacroInputView(
                    isPresented: $showingQuickAdd,
                    userId: userId
                )
                .environmentObject(macrosModel)
            } else {
                Text("Error: No user ID available")
                    .foregroundColor(ColorPalette.error)
            }
        }
        .sheet(isPresented: $showingScanner) {
            BarcodeScannerView(
                scannedBarcode: $scannedBarcode,
                isShowingScanner: $showingScanner,
                isShowingFoodInput: $showingFoodInput,
                isShowingFoodLogging: $showingFoodLogging,
                isShowingBarcodeFoodLogging: $showingBarcodeFoodLogging
            )
            .onChange(of: scannedBarcode) { barcode in
                if !barcode.isEmpty {
                    handleScannedBarcode(barcode)
                }
            }
        }
        .sheet(isPresented: Binding(
            get: { showingFoodInput },
            set: { showingFoodInput = $0 }
        )) {
            FoodInputView(
                isPresented: $showingFoodInput,
                barcode: scannedBarcode,
                userId: userId
            )
        }
        .sheet(isPresented: Binding(
            get: { showingFoodLogging && fetchedFoodItem != nil },
            set: { showingFoodLogging = $0 }
        )) {
            if let food = fetchedFoodItem {
                BarcodeScannedFoodLoggingView(
                    isPresented: $showingFoodLogging,
                    foodItem: LoggedFoodItem(
                        barcode: food.barcode,
                        displayName: food.displayName,
                        calories: food.calories,
                        carbs: food.carbs,
                        protein: food.protein,
                        fat: food.fat,
                        scannedDate: food.scannedDate
                    )
                )
                .environmentObject(macrosModel)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    private func handleScannedBarcode(_ barcode: String) {
        print("Scanned barcode: \(barcode)")
        
        fetchFoodByBarcode(barcode: barcode, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let food):
                    if let food = food {
                        print("Barcode \(barcode) found: \(food)")
                        fetchedFoodItem = food
                        showingFoodLogging = true
                    } else {
                        print("Barcode \(barcode) not found. Transitioning to FoodInputView.")
                        showingFoodInput = true
                    }
                case .failure(let error):
                    print("Error fetching food by barcode: \(error.localizedDescription)")
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}



struct MacroSummaryCardDashboard: View {
    var isAnimating: Bool
    @State private var progressAnimation: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(ModernColors.surface, lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: progressAnimation)
                    .stroke(
                        LinearGradient(
                            colors: [ModernColors.primary, ModernColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.5).delay(0.3), value: progressAnimation)
                
                VStack(spacing: 4) {
                    Text("2000")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(ModernColors.text)
                    Text("calories left")
                        .font(.subheadline)
                        .foregroundColor(ModernColors.muted)
                }
            }
            
            HStack(spacing: 24) {
                MacroIndicator(title: "Carbs", value: 225, target: 300, color: ModernColors.secondary)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                
                MacroIndicator(title: "Protein", value: 120, target: 180, color: ModernColors.primary)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: isAnimating)
                
                MacroIndicator(title: "Fat", value: 45, target: 65, color: ModernColors.accent)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)
            }
        }
        .padding(24)
        .background(ModernColors.surface)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 5)
        .padding(.horizontal)
        .onChange(of: isAnimating) { newValue in
            if newValue {
                progressAnimation = 0.7
            }
        }
    }
}

struct MacroIndicator: View {
    let title: String
    let value: Int
    let target: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(ModernColors.muted)
            Text("\(value)g")
                .font(.headline)
                .foregroundColor(ModernColors.text)
            Text("/ \(target)g")
                .font(.caption2)
                .foregroundColor(ModernColors.muted)
            
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.2))
                    .frame(width: 8, height: 40)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: 8, height: 40 * CGFloat(value) / CGFloat(target))
            }
        }
    }
}

struct QuickActionButtonDashboard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .foregroundColor(ModernColors.text)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(color.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [color.opacity(0.5), color.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    
    DashboardView()
        .environmentObject(LoginModel())
}
