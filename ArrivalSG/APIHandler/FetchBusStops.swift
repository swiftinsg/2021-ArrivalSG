//
//  FetchData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

struct busStops: Codable {
    let value: [busStop]
}

struct busStop: Codable, Hashable {
    let RoadName: String
    let Description: String
    let Latitude: Float32
    let Longitude: Float32
}

struct FetchBusStops {
    enum FetchError: Error {
        case invalidEndpoint
        case missingData
    }
    
    static func fetchBusStops() async throws -> [busStop] {
        guard let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops") else {
            throw FetchError.invalidEndpoint
        }
        
        let (data, _) = try await URLSession.shared.data(from: API_ENDPOINT)
        
        let busStopsResult = try JSONDecoder().decode(busStops.self, from: data)
        return busStopsResult.value
    }
    
}
    
