//
//  busStops.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

struct busStops: Decodable {
    let value: [busStop]
}

struct busStop: Decodable, Hashable {
    let RoadName: String
    let Description: String
    let Latitude: Float32
    let Longitude: Float32
}
