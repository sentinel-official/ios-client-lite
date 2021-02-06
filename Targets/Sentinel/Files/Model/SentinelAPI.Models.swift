//
// Copyright (c) N/A
//

import Darwin
import Swift

typealias Node = SentinelAPI.Models.Node

extension SentinelAPI.Models {
    struct NodeList: Codable {
        let list: [Node]
    }
    
    struct Node: Codable, Hashable {
        struct Location: Codable, Hashable {
            var city: String?
            var country: String?
            var latitude: Double?
            var longitude: Double?
        }
        
        struct Load: Codable, Hashable {
            var cpu: Double?
            var memory: Double?
            
            var description: String {
                guard let memory = memory else {
                    return "---"
                }
                
                let mbps = ceil(memory / (1024 * 1024))
                
                return String(format: "%.2f", mbps)
            }
        }
        
        var ip: String?
        var description: String?
        var account_addr: String?
        var port: String?
        var version: String?
        var enc_method: String?
        var latency: Double?
        var moniker: String?
        var rating: Double?
        var load: Load?
        var location: Location?
    }
}

extension SentinelAPI.Models.Node {
    var latencyDescription: String? {
        guard let latency = latency else {
            return nil
        }
        
        return String(format: "%.2f", latency) + "ms"
    }
    
    var ratingDescription: String? {
        guard let rating = rating else {
            return nil
        }
        
        return String(format: "%.2f", rating)
    }
    
    var name: String {
        if let moniker = moniker?.trimmingWhitespace(), !moniker.isEmpty {
            return moniker
        } else if let country = location?.country, !country.isEmpty {
            return country
        } else {
            return "Node"
        }
    }
}
