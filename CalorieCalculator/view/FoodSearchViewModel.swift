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
    @Published var noResultsMessage: String? // Added for user feedback
    
    private var allFoods: [FoodItem] = []
    private var searchTask: Task<Void, Never>?
    private var searchDebounceTimer: Timer?
    private let resultsPerPage = 20
    
    // Optimized inverted index (kept as is for now, but see notes on trie)
    private var nameIndex: [String: Set<FoodItem>] = [:]
    private var brandIndex: [String: Set<FoodItem>] = [:]
    
    init() {
        loadFoodData()
    }
    
    // Paginate results based on the current search with lazy loading
    var paginatedResults: [FoodItem] {
        let startIndex = currentPage * resultsPerPage
        let endIndex = min(startIndex + resultsPerPage, filteredFoods.count)
        guard startIndex < filteredFoods.count else { return [] }
        return Array(filteredFoods.lazy[startIndex..<endIndex]) // Use lazy to optimize for large datasets
    }
    
    // Build indices once after data is loaded
    private func buildSearchIndices() {
        nameIndex.removeAll()
        brandIndex.removeAll()
        
        for food in allFoods {
            let nameWords = food.displayName.lowercased().split(separator: " ")
            for word in nameWords {
                nameIndex[String(word), default: []].insert(food)
            }
            nameIndex[food.displayName.lowercased(), default: []].insert(food)
            
            if let brand = food.brandName?.lowercased() {
                let brandWords = brand.split(separator: " ")
                for word in brandWords {
                    brandIndex[String(word), default: []].insert(food)
                }
                brandIndex[brand, default: []].insert(food)
            }
        }
    }
    
    // Load the food data asynchronously
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
                let response = try decoder.decode(FoodResponse.self, from: data) // Fixed 'Wdata' to 'data'
                
                await MainActor.run {
                    self.allFoods = response.foods.food
                    self.buildSearchIndices()
                    self.searchResults = []
                    self.isLoading = false
                }
            } catch {
                print("Loading Error: \(error)")
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                    self.noResultsMessage = "Failed to load food data. Please try again."
                }
            }
        }
    }
    
    // Optimized filtering logic using pre-built indices
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
            let combinedMatches = nameMatches.union(brandMatches)
            
            if results == nil {
                results = combinedMatches
            } else {
                results = results?.intersection(combinedMatches)
            }
        }
        
        if results?.isEmpty ?? true {
            results = Set(allFoods.filter { food in
                searchTerms.contains { food.displayName.lowercased().contains($0) || (food.brandName?.lowercased().contains($0) ?? false) }
            })
        }
        
        return Array(results ?? [])
            .sorted {
                let score1 = relevanceScore(for: $0)
                let score2 = relevanceScore(for: $1)
                return score1 == score2 ? $0.displayName < $1.displayName : score1 > score2
            }
    }
    
    // Enhanced relevance scoring
    private func relevanceScore(for food: FoodItem) -> Int {
        let lowercasedSearchText = searchText.lowercased()
        let searchTerms = lowercasedSearchText.split(separator: " ").map(String.init)
        let displayName = food.displayName.lowercased()
        let brandName = food.brandName?.lowercased() ?? ""
        
        var score = 0
        
        for term in searchTerms {
            if displayName == term || brandName == term {
                score += 4  // Exact match for a term
            } else if displayName.hasPrefix(term) || brandName.hasPrefix(term) {
                score += 3  // Prefix match for a term
            } else if displayName.contains(term) || brandName.contains(term) {
                score += 1  // Substring match for a term
            }
        }
        
        // Bonus for full prefix match of the entire search text
        if displayName.hasPrefix(lowercasedSearchText) || brandName.hasPrefix(lowercasedSearchText) {
            score += 2
        }
        
        return score
    }
    
    // Perform the search with increased debounce time and better feedback
    func performSearch() {
        searchTask?.cancel()
        searchDebounceTimer?.invalidate()
        
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.currentPage = 0
            self.isLoading = true
            self.noResultsMessage = nil // Reset message
            
            self.searchTask = Task {
                await MainActor.run {
                    self.searchResults = self.paginatedResults
                    self.isLoading = false
                    if self.searchResults.isEmpty && !self.searchText.isEmpty {
                        self.noResultsMessage = "No results found for '\(self.searchText)'"
                    }
                }
            }
        }
    }
    
    // Load more results when the user scrolls
    func loadMoreResults() {
        currentPage += 1
        searchResults.append(contentsOf: paginatedResults)
    }
}
