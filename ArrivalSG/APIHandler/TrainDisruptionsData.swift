//
//  TrainDisruptionsData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation

struct TrainDisruptionsData: Codable {
    let value: [dataVal]
}

struct dataVal: Codable, Hashable {
    let Status: Int
    let Line: String
    let Direction: String
    let Stations: String
    let FreePublicBus: String
    let FreeMRTShuttle: String
    let MRTShuttleDirection: String
    let Message: String
}
