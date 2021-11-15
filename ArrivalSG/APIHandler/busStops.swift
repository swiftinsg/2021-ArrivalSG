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

struct BusStopLoc: Decodable, Hashable {
    let BusStopCode: String
    let RoadName: String
    let Description: String
    let Latitude: Float32
    let Longitude: Float32
}
