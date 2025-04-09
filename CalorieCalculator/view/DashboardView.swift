//
//  DashboardView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//  Redesigned by Grok 3 on 03/13/25 for xAI.
//  Apple-Inspired Redesign by Grok 3 on 03/13/25.
//  Sidebar Removed and Features Updated by Grok 3 on 03/13/25.
//  Buttons and Macro Card Redesigned by Grok 3 on 03/14/25.
//  Glitches Fixed and Proportions Adjusted by Grok 3 on 03/14/25.
//  Up-and-Down Animation Removed and Macro Prism Added by Grok 3 on 03/15/25.
//  Gradient Animation Fully Removed by Grok 3 on 03/16/25.
//  Fixed by Grok 3 on 03/17/25 to resolve button and data issues.
//  Water Intake and Action Buttons Redesigned by Grok 3 on 04/07/25.
//  Adjusted Water Card Width for Horizontal Button Layout by Grok 3 on 04/07/25.
//  Fixed Button Functionality and Proportions by Grok 3 on 04/07/25.
//  Increased Padding for Edge Safety by Grok 3 on 04/07/25.
//  Removed Comma from Calories Display by Grok 3 on 04/07/25.
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
    @State private var selectedTab = 0
    
    @State private var isAnimating = false
    
    private let username = UserDefaults.standard.string(forKey: "username") ?? "User"
    private let userId = UserDefaults.standard.integer(forKey: "UserId")
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingGlyphsView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    DynamicHeaderView(username: username)
                        .padding(.top, 30)
                        .padding(.horizontal, 24)
                    
                    GlassTabSelector(selectedTab: $selectedTab)
                        .padding(.vertical, 12)
                    
                    TabView(selection: $selectedTab) {
                        TodayView(
                            macrosModel: macrosModel,
                            isAnimating: isAnimating,
                            showingQuickAdd: $showingQuickAdd,
                            showingScanner: $showingScanner
                        )
                        .tag(0)
                        InsightsView(macrosModel: macrosModel, isAnimating: isAnimating)
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .font(.custom("Azeret Mono", size: 16))
            .preferredColorScheme(.dark)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.8)) {
                isAnimating = true
            }
            fetchTodaysMacros()
        }
        .sheet(isPresented: $showingQuickAdd) {
            MacroInputView(isPresented: $showingQuickAdd, userId: userId)
                .environmentObject(macrosModel)
        }
        .sheet(isPresented: $showingScanner) {
            if loginModel.userResponse?.memberType == "Premium" {
                BarcodeScannerView(
                    scannedBarcode: $scannedBarcode,
                    isShowingScanner: $showingScanner,
                    isShowingFoodInput: $showingFoodInput,
                    isShowingFoodLogging: $showingFoodLogging,
                    isShowingBarcodeFoodLogging: $showingBarcodeFoodLogging
                )
                .onChange(of: scannedBarcode) { handleScannedBarcode($0) }
            } else {
                SubscribeToPremiumView()
            }
        }
        .sheet(isPresented: $showingFoodInput) {
            FoodInputView(isPresented: $showingFoodInput, barcode: scannedBarcode, userId: userId)
        }
        .sheet(isPresented: $showingFoodLogging) {
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
    
    private func fetchTodaysMacros() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let today = dateFormatter.string(from: Date())
        macrosModel.fetchMacros(userId: userId, entryDate: today) { _ in }
    }
    
    private func handleScannedBarcode(_ barcode: String) {
        fetchFoodByBarcode(barcode: barcode, userId: userId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let food):
                    fetchedFoodItem = food
                    showingFoodLogging = food != nil
                    showingFoodInput = food == nil
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                ModernColors.background,
                ModernColors.surface.opacity(0.7),
                ModernColors.background.opacity(0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Floating Glyphs
struct FloatingGlyphsView: View {
    @State private var glyphs: [Glyph] = (0..<10).map { _ in Glyph() }
    
    var body: some View {
        ZStack {
            ForEach(glyphs) { glyph in
                RoundedRectangle(cornerRadius: 4)
                    .fill(ModernColors.glyphGlow.opacity(glyph.opacity))
                    .frame(width: glyph.width, height: glyph.height)
                    .position(glyph.position)
                    .rotationEffect(.degrees(glyph.rotation))
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 6...10)),
                        value: glyph.opacity
                    )
            }
        }
    }
}

struct Glyph: Identifiable {
    let id = UUID()
    let position: CGPoint = CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                   y: CGFloat.random(in: 0...UIScreen.main.bounds.height))
    let width: CGFloat = CGFloat.random(in: 10...30)
    let height: CGFloat = CGFloat.random(in: 2...10)
    let rotation: Double = Double.random(in: 0...45)
    var opacity: Double = Double.random(in: 0.05...0.2)
}

// MARK: - Dynamic Header
struct DynamicHeaderView: View {
    let username: String
    @State private var hueRotation: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hello, \(username)")
                .font(.custom("Azeret Mono", size: 36).weight(.semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [ModernColors.primary, ModernColors.highlight, ModernColors.secondary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: ModernColors.primary.opacity(0.4), radius: 8)
               /* .onAppear {
                    withAnimation(.easeInOut(duration: 3.0)) {
                        hueRotation = 45
                    }
                }
                */
            Text(Date(), style: .date)
                .font(.custom("Azeret Mono", size: 16))
                .foregroundColor(ModernColors.muted)
                .padding(.leading, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Glass Tab Selector
struct GlassTabSelector: View {
    @Binding var selectedTab: Int
    private let tabs = ["Today", "Insights"]
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                }) {
                    Text(tabs[index])
                        .font(.custom("Azeret Mono", size: 18).weight(selectedTab == index ? .bold : .regular))
                        .foregroundColor(selectedTab == index ? ModernColors.highlight : ModernColors.muted)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(
                            Capsule()
                                .fill(selectedTab == index ? ModernColors.glassLight : ModernColors.glassDark)
                                .overlay(
                                    Capsule()
                                        .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(6)
        .background(
            Capsule()
                .fill(ModernColors.glassDark)
                .shadow(color: ModernColors.neumorphicShadow.opacity(0.5), radius: 10)
        )
    }
}

// MARK: - Today View
struct TodayView: View {
    @ObservedObject var macrosModel: Macros
    var isAnimating: Bool
    @Binding var showingQuickAdd: Bool
    @Binding var showingScanner: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                MacroDashboardCard(macrosModel: macrosModel, isAnimating: isAnimating)
                QuickTipsCard()
                WaterAndActionRow(
                    showingQuickAdd: $showingQuickAdd,
                    showingScanner: $showingScanner,
                    isAnimating: isAnimating
                )
            }
            .padding(.horizontal, 32) // Increased padding for edge safety
            .padding(.top, 12)
        }
    }
}

// MARK: - Macro Dashboard Card
struct MacroDashboardCard: View {
    @ObservedObject var macrosModel: Macros
    @EnvironmentObject var loginModel: LoginModel
    var isAnimating: Bool
    
    private var calorieGoal: Int { loginModel.userResponse?.requiredCalories ?? 2000 }
    private var consumedCalories: Int { macrosModel.macros.reduce(0) { $0 + $1.calories } }
    private var caloriesLeft: Int { max(calorieGoal - consumedCalories, 0) }
    private var protein: (value: Int, target: Int) { (macrosModel.macros.reduce(0) { $0 + $1.protein }, Int(Double(calorieGoal) * 0.3 / 4)) }
    private var carbs: (value: Int, target: Int) { (macrosModel.macros.reduce(0) { $0 + $1.carbs }, Int(Double(calorieGoal) * 0.45 / 4)) }
    private var fat: (value: Int, target: Int) { (macrosModel.macros.reduce(0) { $0 + $1.fat }, Int(Double(calorieGoal) * 0.25 / 9)) }
    
    @State private var showDetails = false
    
    var body: some View {
        ZStack {
            HexagonShape()
                .fill(ModernColors.glassDark)
                .frame(width: 300, height: 300)
                .overlay(
                    HexagonShape()
                        .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: ModernColors.neumorphicShadow.opacity(0.3), radius: 8, x: 3, y: 3)
            
            VStack(spacing: 8) {
                Text(String(caloriesLeft)) // Changed to direct string conversion to remove comma
                    .font(.custom("Azeret Mono", size: 36).bold())
                    .foregroundStyle(LinearGradient(colors: [ModernColors.highlight, ModernColors.primary], startPoint: .top, endPoint: .bottom))
                Text("cal left")
                    .font(.custom("Azeret Mono", size: 14))
                    .foregroundColor(ModernColors.muted)
            }
            .frame(width: 120, height: 120)
            .background(
                Circle()
                    .fill(ModernColors.glassLight.opacity(0.9))
                    .shadow(color: ModernColors.primary.opacity(0.2), radius: 4)
            )
            
            MacroSegment(name: "Protein", value: protein.value, target: protein.target, color: ModernColors.primary, offset: CGPoint(x: 90, y: -60))
            MacroSegment(name: "Carbs", value: carbs.value, target: carbs.target, color: ModernColors.secondary, offset: CGPoint(x: -90, y: -60))
            MacroSegment(name: "Fat", value: fat.value, target: fat.target, color: ModernColors.accent, offset: CGPoint(x: 0, y: 100))
        }
        .frame(width: 300, height: 300)
        .opacity(isAnimating ? 1 : 0)
        .scaleEffect(isAnimating ? 1 : 0.98)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isAnimating)
        .onTapGesture { withAnimation(.easeInOut) { showDetails.toggle() } }
    }
}

struct HexagonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let side = min(width, height) / 2
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        path.move(to: CGPoint(x: center.x + side * cos(0 * .pi / 3), y: center.y + side * sin(0 * .pi / 3)))
        for i in 1..<6 {
            path.addLine(to: CGPoint(x: center.x + side * cos(Double(i) * .pi / 3), y: center.y + side * sin(Double(i) * .pi / 3)))
        }
        path.closeSubpath()
        return path
    }
}

struct MacroSegment: View {
    let name: String
    let value: Int
    let target: Int
    let color: Color
    let offset: CGPoint
    @State private var progress: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 6) {
            Text(name)
                .font(.custom("Azeret Mono", size: 14).bold())
                .foregroundColor(color)
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(ModernColors.glassLight.opacity(0.5))
                    .frame(width: 40, height: 60)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.opacity(0.9))
                    .frame(width: 40, height: progress * 60)
            }
            Text("\(value)/\(target)g")
                .font(.custom("Azeret Mono", size: 12))
                .foregroundColor(ModernColors.muted)
        }
        .position(x: offset.x + 150, y: offset.y + 150)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                progress = min(CGFloat(value) / CGFloat(target), 1.0)
            }
        }
    }
}

// MARK: - Quick Tips Card
struct QuickTipsCard: View {
    let tips = ["Add more protein to feel fuller!", "Hydrate for better metabolism.", "Balance carbs with fiber."]
    @State private var currentTip = 0
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(ModernColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(ModernColors.highlight)
                Text(tips[currentTip])
                    .font(.custom("Azeret Mono", size: 14))
                    .foregroundColor(ModernColors.text)
                    .layoutPriority(1)
                Spacer()
                Button(action: { currentTip = (currentTip + 1) % tips.count }) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(ModernColors.muted)
                        .padding(.trailing, 8)
                }
            }
            .padding(16)
        }
    }
}

// MARK: - Water and Action Row
struct WaterAndActionRow: View {
    @Binding var showingQuickAdd: Bool
    @Binding var showingScanner: Bool
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            CompactWaterTrackerCard()
                .frame(width: 180) // Adjusted to fit within safer margins
            
            HStack(spacing: 12) {
                QuickAddButton(showingQuickAdd: $showingQuickAdd, isAnimating: isAnimating)
                ScanBarcodeButton(showingScanner: $showingScanner, isAnimating: isAnimating)
            }
        }
    }
}

// MARK: - Compact Water Tracker Card
struct CompactWaterTrackerCard: View {
    @State private var glasses = 0
    let goal = 8
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(ModernColors.glassLight)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ModernColors.neumorphicHighlight.opacity(0.3), lineWidth: 1)
                )
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(ModernColors.surfaceHover, lineWidth: 4)
                        .frame(width: 40, height: 40)
                    Circle()
                        .trim(from: 0, to: CGFloat(glasses) / CGFloat(goal))
                        .stroke(ModernColors.secondary, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                    Text("\(glasses)")
                        .font(.custom("Azeret Mono", size: 12).bold())
                        .foregroundColor(ModernColors.text)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Water")
                        .font(.custom("Azeret Mono", size: 12))
                        .foregroundColor(ModernColors.text)
                    Text("\(goal - glasses) left")
                        .font(.custom("Azeret Mono", size: 10))
                        .foregroundColor(ModernColors.muted)
                }
                
                Spacer()
                
                Button(action: { glasses = min(glasses + 1, goal) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundColor(ModernColors.secondary)
                }
            }
            .padding(12)
        }
    }
}

// MARK: - Quick Add Button
struct QuickAddButton: View {
    @Binding var showingQuickAdd: Bool
    let isAnimating: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            showingQuickAdd = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ModernColors.glassDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(colors: [ModernColors.primary, ModernColors.highlight], startPoint: .top, endPoint: .bottom),
                                lineWidth: isHovered ? 2 : 1
                            )
                    )
                    .shadow(color: ModernColors.neumorphicShadow.opacity(0.4), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ModernColors.primary)
                    Text("Quick Add")
                        .font(.custom("Azeret Mono", size: 10))
                        .foregroundColor(isHovered ? ModernColors.highlight : ModernColors.muted)
                }
            }
        }
        .frame(width: 70, height: 70) // Square dimensions
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .opacity(isAnimating ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: isAnimating)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Scan Barcode Button
struct ScanBarcodeButton: View {
    @Binding var showingScanner: Bool
    let isAnimating: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            showingScanner = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ModernColors.glassDark)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(colors: [ModernColors.secondary, ModernColors.accent], startPoint: .top, endPoint: .bottom),
                                lineWidth: isHovered ? 2 : 1
                            )
                    )
                    .shadow(color: ModernColors.neumorphicShadow.opacity(0.4), radius: 6, x: 0, y: 3)
                
                VStack(spacing: 4) {
                    Image(systemName: "barcode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(ModernColors.secondary)
                    Text("Scan")
                        .font(.custom("Azeret Mono", size: 10))
                        .foregroundColor(isHovered ? ModernColors.accent : ModernColors.muted)
                }
            }
        }
        .frame(width: 70, height: 70) // Square dimensions
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .opacity(isAnimating ? 1 : 0)
        .animation(.easeInOut(duration: 0.4), value: isAnimating)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}

// MARK: - Insights View
struct InsightsView: View {
    @ObservedObject var macrosModel: Macros
    var isAnimating: Bool
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                WeeklyProgressGlassCard(isAnimating: isAnimating)
                NutrientBalanceGlassCard(isAnimating: isAnimating)
                StreakGlassCard(isAnimating: isAnimating)
            }
            .padding(.horizontal, 32) // Increased padding for edge safety
            .padding(.top, 12)
        }
    }
}

// MARK: - Weekly Progress Glass Card
struct WeeklyProgressGlassCard: View {
    var isAnimating: Bool
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let values = [1650, 1830, 1720, 1950, 1800, 1600, 1750]
    let goal = 2000
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Progress")
                .font(.custom("Azeret Mono", size: 24).bold())
                .foregroundColor(ModernColors.text)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(ModernColors.glassDark)
                    .shadow(color: ModernColors.neumorphicShadow.opacity(0.4), radius: 10, x: 4, y: 4)
                
                VStack(spacing: 20) {
                    HStack {
                        Text("Calories")
                            .font(.custom("Azeret Mono", size: 14))
                            .foregroundColor(ModernColors.muted)
                        Spacer()
                        LegendItem(color: ModernColors.primary, label: "Intake")
                        LegendItem(color: ModernColors.surfaceHover, label: "Goal")
                    }
                    
                    HStack(spacing: 10) {
                        ForEach(0..<7) { index in
                            AnimatedBarView(value: values[index], goal: goal, day: days[index])
                        }
                    }
                    
                    HStack {
                        StatDItem(title: "Avg", value: "\(values.reduce(0, +) / values.count)", color: ModernColors.primary)
                        Spacer()
                        StatDItem(title: "Goal", value: "\(goal)", color: ModernColors.secondary)
                    }
                }
                .padding(20)
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: isAnimating)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.custom("Azeret Mono", size: 12))
                .foregroundColor(ModernColors.muted)
        }
    }
}

struct AnimatedBarView: View {
    let value: Int
    let goal: Int
    let day: String
    @State private var height: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(ModernColors.glassLight)
                    .frame(width: 16, height: 100)
                RoundedRectangle(cornerRadius: 4)
                    .fill(ModernColors.primary.opacity(0.9))
                    .frame(width: 16, height: height)
            }
            Text(day)
                .font(.custom("Azeret Mono", size: 10))
                .foregroundColor(ModernColors.muted)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                height = CGFloat(value) / CGFloat(goal) * 100
            }
        }
    }
}

struct StatDItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.custom("Azeret Mono", size: 18).bold())
                .foregroundColor(color)
            Text(title)
                .font(.custom("Azeret Mono", size: 12))
                .foregroundColor(ModernColors.muted)
        }
    }
}

// MARK: - Nutrient Balance Glass Card
struct NutrientBalanceGlassCard: View {
    var isAnimating: Bool
    let nutrients = [
        ("Protein", 35.0, ModernColors.primary),
        ("Carbs", 45.0, ModernColors.secondary),
        ("Fat", 20.0, ModernColors.accent)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nutrient Balance")
                .font(.custom("Azeret Mono", size: 24).bold())
                .foregroundColor(ModernColors.text)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(ModernColors.glassDark)
                    .shadow(color: ModernColors.neumorphicShadow.opacity(0.4), radius: 10, x: 4, y: 4)
                
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(ModernColors.glassLight)
                            .frame(width: 120, height: 120)
                        ForEach(0..<nutrients.count) { index in
                            PieSlice(
                                startAngle: Angle(degrees: index == 0 ? 0 : nutrients[0..<index].map { $0.1 * 3.6 }.reduce(0, +)),
                                endAngle: Angle(degrees: nutrients[0...index].map { $0.1 * 3.6 }.reduce(0, +))
                            )
                            .fill(nutrients[index].2.opacity(0.9))
                            .frame(width: 100, height: 100)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(nutrients, id: \.0) { nutrient in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(nutrient.2)
                                    .frame(width: 12, height: 12)
                                Text(nutrient.0)
                                    .font(.custom("Azeret Mono", size: 14))
                                    .foregroundColor(ModernColors.text)
                                Spacer()
                                Text("\(Int(nutrient.1))%")
                                    .font(.custom("Azeret Mono", size: 14).bold())
                                    .foregroundColor(ModernColors.text)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: isAnimating)
    }
}

struct PieSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}

// MARK: - Streak Glass Card
struct StreakGlassCard: View {
    var isAnimating: Bool
    private let currentStreak = UserDefaults.standard.integer(forKey: "streak")
    private let bestStreak = UserDefaults.standard.integer(forKey: "streak")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Consistency")
                .font(.custom("Azeret Mono", size: 24).bold())
                .foregroundColor(ModernColors.text)
            
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(ModernColors.glassDark)
                    .shadow(color: ModernColors.neumorphicShadow.opacity(0.4), radius: 10, x: 4, y: 4)
                
                HStack(spacing: 20) {
                    StreakItem(
                        icon: "flame.fill",
                        value: currentStreak,
                        label: "Current",
                        color: ModernColors.tertiary
                    )
                    StreakItem(
                        icon: "trophy.fill",
                        value: bestStreak,
                        label: "Best",
                        color: ModernColors.secondary
                    )
                }
                .padding(20)
            }
        }
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: isAnimating)
    }
}

struct StreakItem: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 6)
            Text("\(value)")
                .font(.custom("Azeret Mono", size: 36).bold())
                .foregroundColor(ModernColors.text)
            Text(label)
                .font(.custom("Azeret Mono", size: 14))
                .foregroundColor(ModernColors.muted)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DashboardView()
        .environmentObject(LoginModel())
        .environmentObject(Macros())
}
