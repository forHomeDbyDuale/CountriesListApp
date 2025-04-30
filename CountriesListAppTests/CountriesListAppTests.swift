//
//  CountriesListAppTests.swift
//  CountriesListAppTests
//
//  Created by Duale A on 4/29/25.
//
import XCTest
@testable import CountriesListApp

import XCTest
@testable import CountriesListApp

@MainActor
final class CountriesListAppTests: XCTestCase {

    final class MockNetworkService: NetworkServiceProtocol {
        var countries: [Country] = []
        var shouldFail = false
        var errorToThrow: NetworkError = .unknown

        func request<T: Decodable>(
            url: URL,
            method: String,
            parameters: [String: Any]?,
            completion: @escaping (Result<T, NetworkError>) -> Void
        ) {
            if shouldFail {
                completion(.failure(errorToThrow))
                return
            }

            do {
                let data = try JSONEncoder().encode(countries)
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingFailed(error)))
            }
        }
    }


    var mockService: MockNetworkService!
    var viewModel: CountriesViewModel!
    
    override func setUpWithError() throws {
        mockService = MockNetworkService()
        viewModel = CountriesViewModel(networkManager: mockService)
    }
    
    override func tearDownWithError() throws {
        mockService = nil
        viewModel = nil
    }
    
    func testSuccessfulFetchAndBatchLoad() async throws {
        mockService.countries = (1...50).map {
            Country(name: "Country \($0)", region: "Region", code: "\($0)", capital: "Capital")
        }
        
        let expectation = XCTestExpectation(description: "Did fetch and load batch")
        
        viewModel.onUpdate = {
            if self.viewModel.currentBatch.count == 20 {
                XCTAssertEqual(self.viewModel.allCountries.count, 50)
                expectation.fulfill()
            }
        }
        
        viewModel.fetchCountries()
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testErrorHandlingFromNetworkLayer() async throws {
        mockService.shouldFail = true
        mockService.errorToThrow = .requestFailed(NSError(domain: "Network", code: -1))
        
        let expectation = XCTestExpectation(description: "Handled failure gracefully")
        
        viewModel.onError = { errorMessage in
            XCTAssertTrue(errorMessage.contains("Request failed"))
            expectation.fulfill()
        }
        
        viewModel.fetchCountries()
        await fulfillment(of: [expectation], timeout: 3)
    }
    
    func testPerformanceOfBatchFiltering() throws {
        mockService.countries = (1...1000).map {
            Country(name: "Country \($0)", region: "Region", code: "C\($0)", capital: "Capital \($0)")
        }
        
    }
}
