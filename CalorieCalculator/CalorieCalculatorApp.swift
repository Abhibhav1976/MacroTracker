//
//  CalorieCalculatorApp.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 23/12/24.
//

import SwiftUI

@main
struct CalorieCalculatorApp: App {
    @StateObject private var loginModel = LoginModel()
    @StateObject private var signUpModel = SignUpModel()
    @StateObject private var macrosModel = Macros()

    var body: some Scene {
        WindowGroup { 
            ContentView()
                .environmentObject(loginModel)
                .environmentObject(signUpModel)
                .environmentObject(macrosModel)
        }
    }
}

