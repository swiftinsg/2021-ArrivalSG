//
//  busStops.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

struct BusStops: Decodable {
    let value: [BusStopLoc]
}

struct BusStopsDouble: Decodable {
    let value: [BusStopLocDouble]
}

struct BusStopLoc: Decodable, Hashable {
    let BusStopCode: String
    let RoadName: String
    let Description: String 
    let Latitude: String
    let Longitude: String
}

struct BusStopLocDouble: Decodable, Hashable {
    let BusStopCode: String
    let RoadName: String
    let Description: String
    let Latitude: Double
    let Longitude: Double
    
    func convert() -> BusStopLoc {
        return BusStopLoc(BusStopCode: BusStopCode, RoadName: RoadName, Description: Description, Latitude: String(Latitude), Longitude: String(Longitude))
    }
}
