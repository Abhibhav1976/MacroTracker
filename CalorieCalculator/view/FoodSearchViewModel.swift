//
//  FoodSearchViewModel.swift
//  CalorieCalculator
//
//  Created by Abhibhav RajSingh on 30/12/24.
//  Search Performance Optimized by Grok 3 on 04/13/25.
//

import SwiftUI
import Combine

@MainActor
class FoodSearchViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [FoodItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var currentPage = 0
    @Published var noResultsMessage: String?
    @Published var recentSearches: [String] = [] // NEW: Track recent searches
    
    private var allFoods: [FoodItem] = []
    private var searchTask: Task<Void, Never>?
    private let resultsPerPage = 20
    private var cancellables = Set<AnyCancellable>()
    
    // NEW: Trie for faster prefix-based search
    private var nameTrie = Trie()
    private var brandTrie = Trie()
    
    // NEW: Cache for common foods
    private var commonFoods: [FoodItem] = []
    
    init() {
        // NEW: Load recent searches
        if let savedSearches = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = savedSearches.prefix(5).map { $0 }
        }
        
        // NEW: Load data asynchronously
        Task {
            await loadFoodData()
        }
        
        // NEW: Debounce search input
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.performSearch()
            }
            .store(in: &cancellables)
    }
    
    // NEW: Paginate results with lazy loading
    var paginatedResults: [FoodItem] {
        let startIndex = currentPage * resultsPerPage
        let endIndex = min(startIndex + resultsPerPage, filteredFoods.count)
        guard startIndex < filteredFoods.count else { return [] }
        return Array(filteredFoods[startIndex..<endIndex])
    }
    
    var hasMoreResults: Bool {
        (currentPage + 1) * resultsPerPage < filteredFoods.count
    }
    
    // NEW: Trie-based filtering
    var filteredFoods: [FoodItem] {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        
        let lowercasedSearchText = searchText.lowercased()
        let searchTerms = lowercasedSearchText.split(separator: " ").map(String.init)
        
        var results: Set<FoodItem> = []
        
        // NEW: Use common foods for short queries
        let useCommonFoods = lowercasedSearchText.count <= 3 && !commonFoods.isEmpty
        let baseFoods = useCommonFoods ? commonFoods : allFoods
        
        // NEW: Trie-based search for first term
        if let firstTerm = searchTerms.first {
            let nameMatches = nameTrie.findWords(prefix: firstTerm).compactMap { $0 as? FoodItem }
            let brandMatches = brandTrie.findWords(prefix: firstTerm).compactMap { $0 as? FoodItem }
            results = Set(nameMatches).union(brandMatches)
        }
        
        // Refine with additional terms
        for term in searchTerms.dropFirst() {
            let nameMatches = nameTrie.findWords(prefix: term).compactMap { $0 as? FoodItem }
            let brandMatches = brandTrie.findWords(prefix: term).compactMap { $0 as? FoodItem }
            let combinedMatches = Set(nameMatches).union(brandMatches)
            results = results.intersection(combinedMatches)
        }
        
        // Fallback to substring search if no exact matches
        if results.isEmpty {
            results = Set(baseFoods.filter { food in
                searchTerms.contains { term in
                    food.displayName.lowercased().contains(term) ||
                    (food.brandName?.lowercased().contains(term) ?? false)
                }
            })
        }
        
        return Array(results)
            .sorted {
                let score1 = relevanceScore(for: $0)
                let score2 = relevanceScore(for: $1)
                return score1 == score2 ? $0.displayName < $1.displayName : score1 > score2
            }
    }
    
    private func relevanceScore(for food: FoodItem) -> Int {
        let lowercasedSearchText = searchText.lowercased()
        let searchTerms = lowercasedSearchText.split(separator: " ").map(String.init)
        let displayName = food.displayName.lowercased()
        let brandName = food.brandName?.lowercased() ?? ""
        
        var score = 0
        
        for term in searchTerms {
            if displayName == term || brandName == term {
                score += 4
            } else if displayName.hasPrefix(term) || brandName.hasPrefix(term) {
                score += 3
            } else if displayName.contains(term) || brandName.contains(term) {
                score += 1
            }
        }
        
        if displayName.hasPrefix(lowercasedSearchText) || brandName.hasPrefix(lowercasedSearchText) {
            score += 2
        }
        
        return score
    }
    
    // CHANGED: Asynchronous data loading with caching
    func loadFoodData() async {
        do {
            isLoading = true
            
            // NEW: Check for cached indices
            if let cachedData = loadCachedIndices() {
                allFoods = cachedData.foods
                nameTrie = cachedData.nameTrie
                brandTrie = cachedData.brandTrie
                commonFoods = cachedData.commonFoods
                isLoading = false
                return
            }
            
            guard let url = Bundle.main.url(forResource: "food_raw_responses", withExtension: "json") else {
                throw NSError(domain: "FoodDataError", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "Food data file not found"])
            }
            
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(FoodResponse.self, from: data)
            
            allFoods = response.foods.food
            buildSearchIndices()
            
            // NEW: Cache common foods (e.g., top 100 by usage or predefined)
            commonFoods = Array(allFoods.prefix(100))
            
            // NEW: Save indices to cache
            saveCachedIndices(foods: allFoods, nameTrie: nameTrie, brandTrie: brandTrie, commonFoods: commonFoods)
            
            isLoading = false
        } catch {
            print("Loading Error: \(error)")
            await MainActor.run {
                                self.error = error
                                self.isLoading = false
                                self.noResultsMessage = "Failed to load food data. Please try again."
                            }
        }
    }
    
    // NEW: Build trie-based indices
    private func buildSearchIndices() {
        nameTrie = Trie()
        brandTrie = Trie()
        
        for food in allFoods {
            let nameWords = food.displayName.lowercased().split(separator: " ")
            for word in nameWords {
                nameTrie.insert(word: String(word), value: food)
            }
            nameTrie.insert(word: food.displayName.lowercased(), value: food)
            
            if let brand = food.brandName?.lowercased() {
                let brandWords = brand.split(separator: " ")
                for word in brandWords {
                    brandTrie.insert(word: String(word), value: food)
                }
                brandTrie.insert(word: brand, value: food)
            }
        }
    }
    
    // NEW: Cache management
    private func loadCachedIndices() -> (foods: [FoodItem], nameTrie: Trie, brandTrie: Trie, commonFoods: [FoodItem])? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("foodIndices.cache"),
              FileManager.default.fileExists(atPath: cacheURL.path),
              let data = try? Data(contentsOf: cacheURL),
              let cached = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? FoodIndicesCache else {
            return nil
        }
        return (cached.foods, cached.nameTrie, cached.brandTrie, cached.commonFoods)
    }
    
    private func saveCachedIndices(foods: [FoodItem], nameTrie: Trie, brandTrie: Trie, commonFoods: [FoodItem]) {
        let cache = FoodIndicesCache(foods: foods, nameTrie: nameTrie, brandTrie: brandTrie, commonFoods: commonFoods)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: cache, requiringSecureCoding: false)
            let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("foodIndices.cache")
            try data.write(to: cacheURL)
        } catch {
            print("Cache Save Error: \(error)")
        }
    }
    
    // NEW: Cancel ongoing search
    func cancelSearch() {
        searchTask?.cancel()
        isLoading = false
        noResultsMessage = nil
    }
    
    // CHANGED: Optimized search with trie and recent searches
    func performSearch() {
        searchTask?.cancel()
        
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            noResultsMessage = nil
            return
        }
        
        isLoading = true
        noResultsMessage = nil
        
        searchTask = Task {
            searchResults = paginatedResults
            isLoading = false
            if searchResults.isEmpty {
                noResultsMessage = "No results for '\(searchText)'"
            }
            
            // NEW: Update recent searches
            if !searchText.isEmpty && !recentSearches.contains(searchText) {
                recentSearches.insert(searchText, at: 0)
                if recentSearches.count > 5 {
                    recentSearches.removeLast()
                }
                UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
            }
        }
    }
    
    func loadMoreResults() {
        guard hasMoreResults else { return }
        currentPage += 1
        searchResults.append(contentsOf: paginatedResults)
    }
}

// NEW: Trie implementation for efficient prefix search
class Trie {
    private class Node {
        var children: [Character: Node] = [:]
        var values: [Any] = []
        var isEndOfWord: Bool = false
    }
    
    private let root = Node()
    
    func insert(word: String, value: Any) {
        var current = root
        for char in word.lowercased() {
            if current.children[char] == nil {
                current.children[char] = Node()
            }
            current = current.children[char]!
        }
        current.isEndOfWord = true
        current.values.append(value)
    }
    
    func findWords(prefix: String) -> [Any] {
        var current = root
        for char in prefix.lowercased() {
            guard let nextNode = current.children[char] else { return [] }
            current = nextNode
        }
        return collectValues(from: current)
    }
    
    private func collectValues(from node: Node) -> [Any] {
        var results: [Any] = node.isEndOfWord ? node.values : []
        for (_, child) in node.children {
            results.append(contentsOf: collectValues(from: child))
        }
        return results
    }
}

// NEW: Cache structure
class FoodIndicesCache: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true
    
    let foods: [FoodItem]
    let nameTrie: Trie
    let brandTrie: Trie
    let commonFoods: [FoodItem]
    
    init(foods: [FoodItem], nameTrie: Trie, brandTrie: Trie, commonFoods: [FoodItem]) {
        self.foods = foods
        self.nameTrie = nameTrie
        self.brandTrie = brandTrie
        self.commonFoods = commonFoods
        super.init()
    }
    
    required init?(coder: NSCoder) {
        foods = coder.decodeObject(forKey: "foods") as? [FoodItem] ?? []
        nameTrie = coder.decodeObject(forKey: "nameTrie") as? Trie ?? Trie()
        brandTrie = coder.decodeObject(forKey: "brandTrie") as? Trie ?? Trie()
        commonFoods = coder.decodeObject(forKey: "commonFoods") as? [FoodItem] ?? []
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(foods, forKey: "foods")
        coder.encode(nameTrie, forKey: "nameTrie")
        coder.encode(brandTrie, forKey: "brandTrie")
        coder.encode(commonFoods, forKey: "commonFoods")
    }
}
