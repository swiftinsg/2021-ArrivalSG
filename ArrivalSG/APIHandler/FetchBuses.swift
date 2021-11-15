//
//  FetchBuses.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

struct BusStopsData: Codable {
    let BusStopCode: Int
    let Services: [BusStop]
}

struct BusStop: Codable, Hashable {
    let ServiceNo: String
    let Operator: String
    let NextBus: [Bus]
    let NextBus2: [Bus]
    let NextBus3: [Bus]
}

struct Bus: Codable, Hashable {
    let OriginCode: String
    let DestinationCode: String
    let EstimatedArrival: String
    let Latitude: String
    let Longitude: String
    let VisitNumber: String
    let Load: String
    let Feature: String
    let `Type`: String
}

struct FetchBuses {
    enum FetchError: Error {
        case invalidEndpoint
        case missingData
    }
    
    static func fetchBuses(BusStopCode: Int) async throws -> [busStop] {
        guard let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(BusStopCode)") else {
            throw FetchError.invalidEndpoint
        }
        
        let (data, _) = try await URLSession.shared.data(from: API_ENDPOINT)
        
        let busStopsResult = try JSONDecoder().decode(BusStopsData.self, from: data)
        return busStopsResult.Services
    }
}
