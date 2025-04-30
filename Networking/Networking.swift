//
//  Networking.swift
//  CountriesListApp
//
//  Created by Duale A on 4/29/25.
//

import UIKit



//MARK: - Custom network error to localize errors
    // Could have used provide error but a rule is always i follow the pattern of localizing errors and creating enum for that

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL provided."
        case .requestFailed(let error): return "Request failed: \(error.localizedDescription)"
        case .decodingFailed(let error): return "Failed to decode data: \(error.localizedDescription)"
        case .unknown: return "An unknown error occurred."
        }
    }
}


//MARK: - Protocol to be conformed to by any class that uses this function as a contract. Need for testing and decoupling
     // Any class conforming will use this and not create extra function for simplicity and protocol oriented design
protocol NetworkServiceProtocol {
    func request<T: Decodable>(url: URL,
                               method: String,
                               parameters: [String: Any]?,
                               completion:  @escaping @Sendable (Result<T, NetworkError>) -> Void)
}



//MARK: - NetworkManager
  // I could have uses a singleton but used dependency injection to the viewmodel for easier testing
   // Made it final so that it can optimize method dispatch and no class can subclass it due to its one use for fetching
     // Made it final so it keeps the logic and does not have subclass bugs

final class NetworkManager: NetworkServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(url: URL,
                                method: String = "GET",  // if there was a POST , PUT , DELETE etc . enum HTTPMethod {}  would have been great but only getting data now 
                                parameters: [String: Any]? = nil,
                                completion: @escaping (Result<T, NetworkError>) -> Void) {

        var request = URLRequest(url: url)
        request.httpMethod = method

        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                completion(.failure(.requestFailed(error)))
                return
            }
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                print("[NetworkError] Request failed: \(error)")
                return
            }
            guard let data = data else {
                completion(.failure(.unknown))
                print("[NetworkError] No data received")
                return
            }

            do {
                guard let typedType = [Country].self as? T.Type else {
                    completion(.failure(.decodingFailed(NSError(domain: "TypeCast", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid type cast for decoding"]))))
                    return
                }
                let decoded = try JSONDecoder().decode(typedType, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingFailed(error)))
                print("[NetworkError] Decoding failed: \(error)")
            }
        }.resume()

    }
}
