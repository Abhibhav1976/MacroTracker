//
//  LogView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 27/12/24.
//  Completely Reimagined by Grok 3 (xAI) on March 12, 2025.
//

import SwiftUI

// New Color Scheme: LogColors
enum LogColors {
    static let deepVoid = Color(hex: "0A0A0C")
    static let slateGlow = Color(hex: "1E2528")
    static let neonPulse = Color(hex: "00FFB9")
    static let emberGlow = Color(hex: "FF5E62")
    static let twilightBlue = Color(hex: "4A90E2")
    static let mutedAsh = Color(hex: "6B7280")
    static let brightHaze = Color(hex: "F3F4F6")
    static let shadowVeil = Color(hex: "121418").opacity(0.8)
    static let successFlash = Color(hex: "34D399")
    static let warningFlare = Color(hex: "FBBF24")
    static let errorSpike = Color(hex: "F87171")
}

// Compact Floating Card Modifier
struct FloatingCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(LogColors.slateGlow)
            .cornerRadius(12)
            .shadow(color: LogColors.shadowVeil, radius: 8, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LogColors.neonPulse.opacity(0.2), lineWidth: 1)
            )
    }
}

extension View {
    func floatingCard() -> some View {
        modifier(FloatingCard())
    }
}

// Subtle Pulse Animation for Buttons
struct PulseButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.8 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension View {
    func pulseButton() -> some View {
        buttonStyle(PulseButtonStyle())
    }
}

struct LogView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject var fetchMacro = Macros()
    @State private var macros: [MacroResponse] = []
    @State private var selectedDate = Date()
    @State private var isMacroInputPresented = false
    @State private var expandedMealTypes: Set<String> = ["Breakfast", "Lunch", "Dinner", "Snacks"]
    @State private var animateElements = false
    
    private let userId = UserDefaults.standard.integer(forKey: "UserId")
    
    var body: some View {
        ZStack {
            // Background with Subtle Noise Texture
            LogColors.deepVoid
                .overlay(
                    Image(systemName: "square.grid.3x3.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600, height: 600)
                        .foregroundColor(LogColors.neonPulse.opacity(0.02))
                        .rotationEffect(.degrees(45))
                        .offset(x: 100, y: -200)
                )
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                // Header with Compact Date Selector
                headerView
                    .padding(.top, 40)
                    .padding(.horizontal, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        MacroPulseSummary(macros: macros)
                            .padding(.top, 16)
                            .padding(.horizontal, 20)
                        
                        CompactMealTimeline(
                            macros: macros,
                            expandedMealTypes: $expandedMealTypes
                        )
                        .padding(.bottom, 40)
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
            withAnimation(.easeInOut(duration: 0.6)) {
                animateElements = true
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Text("Log")
                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                .foregroundColor(LogColors.brightHaze)
                .shadow(color: LogColors.neonPulse.opacity(0.3), radius: 4)
                .opacity(animateElements ? 1 : 0)
                .offset(y: animateElements ? 0 : -20)
            
            // Redesigned Date Selector: Compact Slider Style
            HStack(spacing: 12) {
                Button(action: { changeDate(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(LogColors.twilightBlue)
                        .frame(width: 32, height: 32)
                        .background(LogColors.slateGlow)
                        .cornerRadius(8)
                }
                .pulseButton()
                
                Text(selectedDate.formatted(.dateTime.day().month().year()))
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(LogColors.brightHaze)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(LogColors.shadowVeil)
                    .cornerRadius(8)
                    .shadow(color: LogColors.neonPulse.opacity(0.1), radius: 4)
                
                Button(action: { changeDate(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(LogColors.twilightBlue)
                        .frame(width: 32, height: 32)
                        .background(LogColors.slateGlow)
                        .cornerRadius(8)
                }
                .pulseButton()
                
                Spacer()
                
                Button(action: { isMacroInputPresented = true }) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(LogColors.neonPulse)
                        .frame(width: 40, height: 40)
                        .background(LogColors.slateGlow)
                        .cornerRadius(20)
                        .shadow(color: LogColors.neonPulse.opacity(0.4), radius: 6)
                }
                .pulseButton()
            }
            .opacity(animateElements ? 1 : 0)
            .offset(y: animateElements ? 0 : 20)
        }
    }
    
    private func fetchMacrosForDate() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        fetchMacro.fetchMacros(userId: userId, entryDate: dateFormatter.string(from: selectedDate)) { result in
            if case .success(let fetchedMacros) = result {
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.macros = fetchedMacros
                }
            }
        }
    }
    
    private func changeDate(by days: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
                selectedDate = newDate
                fetchMacrosForDate()
            }
        }
    }
}

// Compact Macro Summary with Design from Photo
struct MacroPulseSummary: View {
    let macros: [MacroResponse]
    @State private var animatePulse = false
    
    var body: some View {
        let summary = macros.summary
        
        VStack(spacing: 16) {
            // Calories Circle with Glowing Border
            ZStack {
                Circle()
                    .stroke(LogColors.neonPulse.opacity(0.5), lineWidth: 4)
                    .frame(width: 120, height: 120)
                    .scaleEffect(animatePulse ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animatePulse)
                
                Circle()
                    .fill(LogColors.deepVoid)
                    .frame(width: 110, height: 110)
                
                VStack(spacing: 4) {
                    Text("\(summary.calories)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(LogColors.brightHaze)
                    Text("Energy Core")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(LogColors.neonPulse)
                }
            }
            
            // Macro Circles
            HStack(spacing: 20) {
                MacroCircle(
                    title: "Protein",
                    value: summary.protein.total,
                    target: summary.protein.target,
                    color: LogColors.successFlash
                )
                MacroCircle(
                    title: "Carbs",
                    value: summary.carbs.total,
                    target: summary.carbs.target,
                    color: LogColors.twilightBlue
                )
                MacroCircle(
                    title: "Fat",
                    value: summary.fat.total,
                    target: summary.fat.target,
                    color: LogColors.emberGlow
                )
            }
        }
        .padding(20)
        .background(LogColors.deepVoid)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(LogColors.neonPulse.opacity(0.5), lineWidth: 2)
        )
        .onAppear {
            animatePulse = true
        }
    }
}

// Circular Progress Indicator for Macros
struct MacroCircle: View {
    let title: String
    let value: Int
    let target: Int
    let color: Color
    
    var percentage: CGFloat {
        min(CGFloat(value) / CGFloat(target), 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(LogColors.mutedAsh.opacity(0.3), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: percentage)
                    .stroke(color, lineWidth: 4)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: percentage)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(LogColors.brightHaze)
            
            Text("\(value)/\(target)g")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(LogColors.mutedAsh)
        }
    }
}

// Supporting Structs (unchanged functionality)
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
            MacroSummary(total: protein, target: 180, color: LogColors.successFlash),
            MacroSummary(total: fat, target: 65, color: LogColors.emberGlow),
            MacroSummary(total: carbs, target: 225, color: LogColors.twilightBlue),
            calories
        )
    }
}

extension MacroResponse {
    var uniqueId: String {
        "\(mealType)-\(calories)-\(carbs)-\(protein)-\(fat)"
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
            .environmentObject(LoginModel())
    }
}
