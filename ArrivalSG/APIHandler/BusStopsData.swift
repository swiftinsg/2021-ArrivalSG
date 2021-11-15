//
//  BusStopsData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

struct BusStopsData: Decodable {
    let BusStopCode: Int
    let Services: [BusStop]
}

struct BusStop: Decodable, Hashable {
    let ServiceNo: String
    let Operator: String
    let NextBus: [Bus]
    let NextBus2: [Bus]
    let NextBus3: [Bus]
}

struct Bus: Decodable, Hashable {
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