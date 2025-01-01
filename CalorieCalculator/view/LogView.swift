//
//  LogView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 27/12/24.
//

import SwiftUI

enum ColorSystem {
    static let background = Color(hex: "09090B")
    static let surface = Color(hex: "18181B")
    static let surfaceHover = Color(hex: "27272A")
    static let primary = Color(hex: "22C55E")
    static let primaryHover = Color(hex: "16A34A")
    static let secondary = Color(hex: "3B82F6")
    static let secondaryHover = Color(hex: "2563EB")
    static let accent = Color(hex: "8B5CF6")
    static let muted = Color(hex: "71717A")
    static let text = Color(hex: "FAFAFA")
    static let textSecondary = Color(hex: "A1A1AA")
    static let border = Color(hex: "27272A")
    static let error = Color(hex: "EF4444")
    static let warning = Color(hex: "F59E0B")
    static let success = Color(hex: "10B981")
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ColorSystem.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(ColorSystem.border, lineWidth: 1)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

struct MacroSummary {
    let total: Int
    let target: Int
    let color: Color
    
    var percentage: Double {
        min(Double(total) / Double(target), 1.0)
    }
}

extension Collection where Element == MacroResponse {
    var summary: (protein: MacroSummary, fat: MacroSummary, carbs: MacroSummary, calories: Int) {
        let protein = self.reduce(0) { $0 + $1.protein }
        let fat = self.reduce(0) { $0 + $1.fat }
        let carbs = self.reduce(0) { $0 + $1.carbs }
        let calories = self.reduce(0) { $0 + $1.calories }
        
        return (
            MacroSummary(total: protein, target: 180, color: ColorSystem.success),
            MacroSummary(total: fat, target: 65, color: ColorSystem.warning),
            MacroSummary(total: carbs, target: 225, color: ColorSystem.secondary),
            calories
        )
    }
}

extension MacroResponse {
    var uniqueId: String {
        "\(mealType)-\(calories)-\(carbs)-\(protein)-\(fat)"
    }
}


struct LogView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject var fetchMacro = Macros()
    @State private var macros: [MacroResponse] = []
    @State private var selectedDate = Date()
    @State private var isMacroInputPresented = false
    @State private var expandedMealTypes: Set<String> = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    @State private var animateHeader = false
    @State private var showDatePicker = false
    
    private let username = UserDefaults.standard.string(forKey: "username") ?? "No username"
    private let userId = UserDefaults.standard.integer(forKey: "UserId")
    
    var body: some View {
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
                // Modern Header with Date Selector
                headerView
                    .padding(.top)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        CompactMacroSummary(macros: macros)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        MealList(
                            macros: macros,
                            expandedMealTypes: $expandedMealTypes
                        )
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $isMacroInputPresented) {
            MacroInputView(isPresented: $isMacroInputPresented, userId: userId)
                .environmentObject(fetchMacro)
        }
        .onAppear {
            fetchMacrosForDate()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateHeader = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Hello, \(username)")
                    .font(.title2.bold())
                    .foregroundColor(ModernColors.text)
                
                Spacer()
                
                Button(action: { isMacroInputPresented = true }) {
                    ZStack {
                        Circle()
                            .fill(ModernColors.primary)
                            .frame(width: 40, height: 40)
                            .shadow(color: ModernColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(animateHeader ? 1 : 0)
            }
            .padding(.horizontal)
            
            // Modern Date Selector
            Button(action: { withAnimation { showDatePicker.toggle() } }) {
                HStack(spacing: 12) {
                    HStack {
                        Button(action: { changeDate(by: -1) }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ModernColors.text)
                        }
                        
                        Text(selectedDate.formatted(.dateTime.day().month().year()))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(ModernColors.text)
                        
                        Button(action: { changeDate(by: 1) }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(ModernColors.text)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ModernColors.surface)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                }
            }
            .offset(y: animateHeader ? 0 : -20)
            .opacity(animateHeader ? 1 : 0)
        }
        .padding(.bottom, 8)
    }
    
    private func fetchMacrosForDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        fetchMacro.fetchMacros(userId: userId, entryDate: dateFormatter.string(from: selectedDate)) { result in
            if case .success(let fetchedMacros) = result {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    self.macros = fetchedMacros
                }
            }
        }
    }
    
    private func changeDate(by days: Int) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
                selectedDate = newDate
                fetchMacrosForDate()
            }
        }
    }
}

struct CompactMacroSummary: View {
    let macros: [MacroResponse]
    @State private var animateCards = false
    
    var body: some View {
        let summary = macros.summary
        
        VStack(spacing: 16) {
            // Calories Card
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Calories")
                        .font(.subheadline)
                        .foregroundColor(ModernColors.muted)
                    
                    Text("\(summary.calories)")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(ModernColors.text)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(ModernColors.surface, lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: min(CGFloat(summary.calories) / 2500.0, 1.0))
                        .stroke(ModernColors.primary, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 1, dampingFraction: 0.8), value: summary.calories)
                }
            }
            .padding(20)
            .background(ModernColors.surface)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .offset(x: animateCards ? 0 : -30)
            .opacity(animateCards ? 1 : 0)
            
            // Macros Grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
            ], spacing: 16) {
                MacroCard(
                    title: "Protein",
                    current: summary.protein.total,
                    target: summary.protein.target,
                    color: summary.protein.color
                )
                .offset(x: animateCards ? 0 : 30)
                .opacity(animateCards ? 1 : 0)
                
                MacroCard(
                    title: "Carbs",
                    current: summary.carbs.total,
                    target: summary.carbs.target,
                    color: summary.carbs.color
                )
                .offset(x: animateCards ? 0 : -30)
                .opacity(animateCards ? 1 : 0)
                
                MacroCard(
                    title: "Fat",
                    current: summary.fat.total,
                    target: summary.fat.target,
                    color: summary.fat.color
                )
                .offset(x: animateCards ? 0 : 30)
                .opacity(animateCards ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateCards = true
            }
        }
    }
}

struct MacroCard: View {
    let title: String
    let current: Int
    let target: Int
    let color: Color
    
    private var percentage: Double {
        Double(current) / Double(target)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(ModernColors.muted)
                Spacer()
            }
            
            ZStack(alignment: .leading) {
                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.2))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(percentage, 1.0)))
                        .animation(.spring(response: 1, dampingFraction: 0.8), value: percentage)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(current)g")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(ModernColors.text)
                
                Text("/ \(target)g")
                    .font(.system(size: 16))
                    .foregroundColor(ModernColors.muted)
            }
        }
        .padding(16)
        .background(ModernColors.surface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// Extension for View to add press animation
extension View {
    func pressAnimation() -> some View {
        self.buttonStyle(PressButtonStyle())
    }
}

struct PressButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct MealList: View {
    let macros: [MacroResponse]
    @Binding var expandedMealTypes: Set<String>
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(["Breakfast", "Lunch", "Dinner", "Snacks"], id: \.self) { mealType in
                if let meals = Dictionary(grouping: macros) { $0.mealType }[mealType] {
                    MealSection(
                        mealType: mealType,
                        meals: meals,
                        isExpanded: expandedMealTypes.contains(mealType),
                        onToggle: { isExpanded in
                            if isExpanded {
                                expandedMealTypes.insert(mealType)
                            } else {
                                expandedMealTypes.remove(mealType)
                            }
                        }
                    )
                }
            }
        }
    }
}

