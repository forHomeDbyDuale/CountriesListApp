//
//  CountriesModel.swift
//  CountriesListApp
//
//  Created by Duale A on 4/29/25.
//

import Foundation


// Made it this way since i guess the country code is unique and easy for comparison

struct Country: Codable, Hashable, Equatable, Identifiable {
    let name: String
    let region: String
    let code: String
    let capital: String

    var id: String { code }

    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.code == rhs.code
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }
}
