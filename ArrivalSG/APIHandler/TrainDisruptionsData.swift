//
//  TrainDisruptionsData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation

struct TrainDisruptionsData: Codable {
    let Status: Int
    let Message: [msg]
    let AffectedSegments: [affectedSeg]
}
struct affectedSeg: Codable, Hashable {
    let Line: String
    let Direction: String
    let Stations: String
    let FreePublicBus: String
    let FreeMRTShuttle: String
    let MRTShuttleDirection: String
}

struct msg: Codable, Hashable {
    let Content: String
    let CreatedDate: String
}
