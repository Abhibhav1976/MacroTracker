//
//  FoodInputView.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 31/12/24.
//

import SwiftUI

struct FoodInputView: View {
    @Binding var isPresented: Bool
    @State private var foodName: String = ""
    @State private var calories: String = ""
    @State private var carbs: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var showingFeedback = false
    @State private var isSuccess = false
    @State private var feedbackMessage = ""
    
    let barcode: String
    let userId: Int
    
    var body: some View {
            NavigationView {
                ZStack {
                    ColorPalette.background.ignoresSafeArea()
                    
                    if showingFeedback {
                        if isSuccess {
                            SuccessView(
                                message: feedbackMessage,
                                isPresented: $showingFeedback
                            )
                        } else {
                            ErrorView(
                                message: feedbackMessage,
                                isPresented: $showingFeedback
                            )
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                Text("Add Food Details")
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 16) {
                                    StyledTextField(placeholder: "Food Name", text: $foodName, keyboardType: .default)
                                    StyledTextField(placeholder: "Calories", text: $calories, keyboardType: .numberPad)
                                    StyledTextField(placeholder: "Carbs (g)", text: $carbs, keyboardType: .decimalPad)
                                    StyledTextField(placeholder: "Protein (g)", text: $protein, keyboardType: .decimalPad)
                                    StyledTextField(placeholder: "Fat (g)", text: $fat, keyboardType: .decimalPad)
                                }
                                .padding()
                                
                                Button(action: saveFoodInfo) {
                                    Text("Save Food")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(ColorPalette.primaryButton)
                                        .cornerRadius(10)
                                }
                                .padding()
                            }
                        }
                    }
                }
                .navigationBarItems(leading: Button("Cancel") {
                    isPresented = false
                })
                .onAppear {
                                // Debug log to verify the barcode value
                                print("FoodInputView received barcode: \(barcode)")
                            }
            }
        }
    
    private func saveFoodInfo() {
           guard let caloriesInt = Int(calories),
                 let carbsDouble = Double(carbs),
                 let proteinDouble = Double(protein),
                 let fatDouble = Double(fat) else {
               feedbackMessage = "Please enter valid numbers"
               isSuccess = false
               showingFeedback = true
               return
           }
           
           fetchFoodInfo(
               barcode: barcode,
               foodName: foodName,
               calories: caloriesInt,
               carbs: carbsDouble,
               protein: proteinDouble,
               fat: fatDouble,
               userId: userId
           ) { result in
               DispatchQueue.main.async {
                   switch result {
                   case .success(let scannedFood):
                       feedbackMessage = scannedFood.message
                       isSuccess = true
                       showingFeedback = true
                       // Auto-dismiss the entire view after success
                       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           isPresented = false
                       }
                   case .failure(let error):
                       feedbackMessage = error.localizedDescription
                       isSuccess = false
                       showingFeedback = true
                   }
               }
           }
       }
   }
