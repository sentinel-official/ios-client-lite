//
// Copyright (c) N/A
//

import SwiftUIX

struct Country: Codable {
    let id: Int
    let name: String
    let alpha2: String
    let alpha3: String
}

struct CountryExtra: Codable {
    let alpha2: String
    let capital: String?
    let area: String?
    let population: String?
    let continent: String
}

struct Continents {
    static var continentMap: [String: String] = [
        "AF": "Africa",
        "SA": "South America",
        "NA": "North America",
        "OC": "Oceania",
        "AS": "Asia",
        "EU": "Europe",
        "AN": "Antarctica"
    ]
    
    static var countryToContinent: [String: String] = [:]
    static var countryNameToCountryMap: [String: Country] = [:]
    
    static func createCountryToContinentMap() {
        let countriesURL = Bundle.main.url(forResource: "co.sentinel.sentinellite.regional.countries", withExtension: "json")!
        let countriesExtraURL = Bundle.main.url(forResource: "co.sentinel.sentinellite.regional.countries_extras", withExtension: "json")!
        
        let countriesData = try! Data(contentsOf: countriesURL, options: [])
        let countriesExtraData = try! Data(contentsOf: countriesExtraURL, options: [])
        
        let countries = try! JSONDecoder().decode([Country].self, from: countriesData)
        let countriesExtra = try! JSONDecoder().decode([CountryExtra].self, from: countriesExtraData)
        
        var alpha2ToCountryMap: [String: Country] = [:]
        var alpha2ToCountryExtraMap: [String: CountryExtra] = [:]
        
        for country in countries {
            alpha2ToCountryMap[country.alpha2.uppercased()] = country
            countryNameToCountryMap[country.name] = country
        }
        
        for countryExtra in countriesExtra {
            alpha2ToCountryExtraMap[countryExtra.alpha2.uppercased()] = countryExtra
        }
        
        for key in alpha2ToCountryMap.keys {
            let country = alpha2ToCountryMap[key]
            let countryExtra = alpha2ToCountryExtraMap[key]
            
            if let country = country, let countryExtra = countryExtra {
                countryToContinent[country.name] = continentMap[countryExtra.continent]
            }
        }
    }
}
