//
//  FoodSearchViewModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//

import SwiftUI

@MainActor
class FoodSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [FoodItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 0
    
    private var allFoods: [FoodItem] = []
    private var searchTask: Task<Void, Never>?
    private var searchDebounceTimer: Timer? 
    private let resultsPerPage = 20
    
    private var nameIndex: [String: Set<FoodItem>] = [:]
    private var brandIndex: [String: Set<FoodItem>] = [:]
    
    init() {
        loadFoodData()
    }
    
    var paginatedResults: [FoodItem] {
            let startIndex = currentPage * resultsPerPage
            let endIndex = min(startIndex + resultsPerPage, filteredFoods.count)
            guard startIndex < filteredFoods.count else { return [] }
            return Array(filteredFoods[startIndex..<endIndex])
        }
    
    private func buildSearchIndices() {
        nameIndex.removeAll()
        brandIndex.removeAll()
        
        for food in allFoods {
            // Index words in food name
            let nameWords = food.displayName.lowercased().split(separator: " ")
            for word in nameWords {
                nameIndex[String(word), default: []].insert(food)
            }
            
            // Index words in brand name
            if let brand = food.brandName?.lowercased() {
                let brandWords = brand.split(separator: " ")
                for word in brandWords {
                    brandIndex[String(word), default: []].insert(food)
                }
            }
        }
    }
    
    func loadFoodData() {
        Task {
            do {
                isLoading = true
                
                guard let url = Bundle.main.url(forResource: "food_raw_responses", withExtension: "json") else {
                    throw NSError(domain: "FoodDataError", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Food data file not found"])
                }
                
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let response = try decoder.decode(FoodResponse.self, from: data)
                
                await MainActor.run {
                    self.allFoods = response.foods.food
                    self.buildSearchIndices()  // Build indices after loading data
                    self.searchResults = []
                    self.isLoading = false
                }
            } catch {
                print("Loading Error: \(error)")
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
    
    var filteredFoods: [FoodItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        
        let searchTerms = searchText.lowercased().split(separator: " ").map(String.init)
        
        var results: Set<FoodItem>?
        if let firstTerm = searchTerms.first {
            let nameMatches = nameIndex[firstTerm] ?? []
            let brandMatches = brandIndex[firstTerm] ?? []
            results = nameMatches.union(brandMatches)
        }
        
        for term in searchTerms.dropFirst() {
            let nameMatches = nameIndex[term] ?? []
            let brandMatches = brandIndex[term] ?? []
            results = results?.intersection(nameMatches.union(brandMatches))
        }
        
        return Array(results ?? [])
            .sorted { $0.displayName < $1.displayName }
    }
    
    func performSearch() {
            searchTask?.cancel()
            searchDebounceTimer?.invalidate()
            
            searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                self?.currentPage = 0
                self?.searchTask = Task {
                    await MainActor.run {
                        self?.searchResults = self?.paginatedResults ?? []
                    }
                }
            }
        }
    
    func loadMoreResults() {
            currentPage += 1
            searchResults.append(contentsOf: paginatedResults)
        }

}
