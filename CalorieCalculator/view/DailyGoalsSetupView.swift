//
//  DailyGoalsSetupView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on [Today's Date].
//

import SwiftUI

struct DailyGoalsSetupView: View {
    @EnvironmentObject var loginModel: LoginModel
    @StateObject private var updateModel = UpdateModel()
    @Environment(\.presentationMode) var presentationMode

    // Step counter (0...4 for five questions)
    @State private var step: Int = 0

    // Input fields (as strings)
    @State private var currentWeight: String = ""
    @State private var targetWeight: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var requiredCalories: String = ""

    @State private var isUpdating: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text(promptTitle)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            TextField("Enter value", text: bindingForCurrentStep)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(keyboardTypeForCurrentStep)
                .padding(.horizontal)
            
            if isUpdating {
                ProgressView("Updating...")
            }
            
            Button(action: nextStep) {
                Text(step == 4 ? "Finish" : "Next")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(bindingForCurrentStep.wrappedValue.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(8)
            }
            .disabled(bindingForCurrentStep.wrappedValue.isEmpty || isUpdating)
            .padding(.horizontal)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - UI Helpers
    
    var promptTitle: String {
        switch step {
        case 0: return "What is your current weight (kg)?"
        case 1: return "What is your target weight (kg)?"
        case 2: return "What is your age?"
        case 3: return "What is your height (cm)?"
        case 4: return "What is your daily calorie intake goal?"
        default: return ""
        }
    }
    
    var bindingForCurrentStep: Binding<String> {
        switch step {
        case 0: return $currentWeight
        case 1: return $targetWeight
        case 2: return $age
        case 3: return $height
        case 4: return $requiredCalories
        default: return .constant("")
        }
    }
    
    var keyboardTypeForCurrentStep: UIKeyboardType {
        // For age and calorie intake, use number pad; others allow decimals.
        switch step {
        case 2, 4:
            return .numberPad
        default:
            return .decimalPad
        }
    }
    
    // MARK: - Actions
    
    func nextStep() {
        if step < 4 {
            step += 1
        } else {
            // Validate all fields and update the profile.
            guard let currentWeightValue = Double(currentWeight),
                  let targetWeightValue = Double(targetWeight),
                  let ageValue = Int(age),
                  let heightValue = Double(height),
                  let requiredCaloriesValue = Int(requiredCalories) else {
                errorMessage = "Please ensure all fields have valid values."
                showError = true
                return
            }
            
            isUpdating = true
            updateModel.updateProfile(
                age: ageValue,
                currentWeight: currentWeightValue,
                targetWeight: targetWeightValue,
                requiredCalories: requiredCaloriesValue,
                height: heightValue,
                activityLevel: nil,
                gender: nil,
                goalType: nil,
                profilePicture: nil
            ) { result in
                DispatchQueue.main.async {
                    isUpdating = false
                    switch result {
                    case .success:
                        finishSetup()
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }
        }
    }
    
    func finishSetup() {
        // Update the flag so this setup isn't shown again.
        UserDefaults.standard.set(true, forKey: "isDailyGoalsSetupComplete")
        // Optionally update loginModel.userResponse if needed.
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    DailyGoalsSetupView()
        .environmentObject(LoginModel())
}
