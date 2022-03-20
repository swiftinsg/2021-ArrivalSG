//
//  CarparkAvailability.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/3/22.
//

import Foundation

struct CarparkAvailabilityData: Codable {
    let value: [CarparkAvailabilityMData]
}

struct CarparkAvailabilityMData: Codable, Hashable {
    let CarParkID: String
    let Area: String
    let Development: String
    let Location: String
    let AvailableLots: Int
    let LotType: String
    let Agency: String
}

struct formattedCarparkData: Codable, Hashable {
    var CarParkID: String
    var Area: String
    var Development: String
    var Location: String
    var AvailableLots: [String:String]
    var LotType: String
    var Agency: String
}
