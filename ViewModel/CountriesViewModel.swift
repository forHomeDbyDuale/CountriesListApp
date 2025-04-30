//
//  CountriesViewModel.swift
//  CountriesListApp
//
//  Created by Duale A on 4/29/25.
//


import UIKit

// MARK: - Countries View Model - This is used for MVVM where this class alone can be tested as i used in the test
@MainActor
final class CountriesViewModel {
    private let networkManager: NetworkServiceProtocol
    private let endpoint = "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json"
    private(set) var allCountries: [Country] = []
    private(set) var filteredCountries: [Country] = []
    private(set) var currentBatch: [Country] = []
    private let batchSize = 20
    private var isLoading = false
    
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(networkManager: NetworkServiceProtocol = NetworkManager()) { // Here used dependency injection for avoid tight coupling and easier testing 
        self.networkManager = networkManager
    }
    
    func fetchCountries() {
        guard let url = URL(string: endpoint) else {
            onError?(NetworkError.invalidURL.localizedDescription)
            return
        }
        
        isLoading = true
        
        networkManager.request(url: url, method: "GET", parameters: nil, completion: { [weak self] (result: Result<[Country], NetworkError>) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let countries):
                    self.allCountries = countries
                    self.filteredCountries = countries
                    self.loadNextBatch(reset: true)
                case .failure(let error):
                    self.onError?(error.localizedDescription)
                }
            }
        })
    }
    
    // laoding in batches with batchSize = twenty at a time
    func loadNextBatch(reset: Bool = false) {
        if reset {
            currentBatch.removeAll()
        }
        
        guard currentBatch.count < filteredCountries.count else { return }
        
        let nextBatch = filteredCountries.dropFirst(currentBatch.count).prefix(batchSize)
        currentBatch.append(contentsOf: nextBatch)
        onUpdate?()
    }
    
    
    
    func refreshData() {
        fetchCountries()
    }
    
    func filterCountries(query: String) {
        guard !query.isEmpty else {
            filteredCountries = allCountries
            loadNextBatch(reset: true)
            return
        }
        
        filteredCountries = allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            $0.capital.localizedCaseInsensitiveContains(query)
        }
        loadNextBatch(reset: true)
    }
}
