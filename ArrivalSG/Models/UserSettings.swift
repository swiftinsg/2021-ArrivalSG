//
//  UserSettings.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import Combine
import MapKit

class UserSettings: ObservableObject {
    let userDefaults = UserDefaults.standard
    
    @Published var sgBusStops: [Int] {
        didSet {
            userDefaults.set(sgBusStops, forKey: "sgBusStops")
        }
    }
    
    @Published var busStopData: [[String:Any]] {
        didSet {
            userDefaults.set(busStopData, forKey: "busStopData")
        }
    }
    
    @Published var sgBusStopLoc: [[String:Any]] {
        didSet {
            userDefaults.set(sgBusStopLoc, forKey: "sgBusStopLoc")
        }
    }
    
    @Published var trainDisruptions: TrainDisruptionsData {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(trainDisruptions)
            userDefaults.set(data, forKey: "trainDisruptions")
        }
    }
    
    @Published var isFirstOpen: Bool {
        didSet {
            userDefaults.set(isFirstOpen, forKey: "isFirstOpen")
        }
    }
    
    @Published var favouritedBusStops: [Int] {
        didSet {
            userDefaults.set(favouritedBusStops, forKey: "favouritedBusStops")
        }
    }
    
    @Published var lastUpdatedBus: Date {
        didSet {
            userDefaults.set(favouritedBusStops, forKey: "lastUpdatedBus")
        }
    }
    
    @Published var carparkAvailability: [CarparkAvailabilityMData] {
        didSet {
            let encoder = JSONEncoder()
            let data = try? encoder.encode(carparkAvailability)
            userDefaults.set(data, forKey: "carparkAvailability")
        }
    }
    
    
    init() {
        let decoder = JSONDecoder()

        self.sgBusStops = userDefaults.object(forKey: "sgBusStops") as? [Int] ?? []
        self.busStopData = userDefaults.object(forKey: "busStopData") as? [[String:Any]] ?? [[:]]
        self.sgBusStopLoc = userDefaults.object(forKey: "sgBusStopLoc") as? [[String:Any]] ?? [[:]]
        self.favouritedBusStops = userDefaults.object(forKey: "favouritedBusStops") as? [Int] ?? []
        let trainDisruptionsDat = userDefaults.object(forKey: "trainDisruptions") as? Data
        if let trainDisruptionsDat = trainDisruptionsDat {
            let disruptions = try? decoder.decode(TrainDisruptionsData.self, from: trainDisruptionsDat)
            self.trainDisruptions = disruptions ?? TrainDisruptionsData(Status: 1, Message: [msg(Content: "", CreatedDate: "")], AffectedSegments: [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")])
        } else {
            self.trainDisruptions = TrainDisruptionsData(Status: 1, Message: [msg(Content: "", CreatedDate: "")], AffectedSegments: [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")])
        }
        self.trainDisruptions = userDefaults.object(forKey: "trainDisruptions") as? TrainDisruptionsData ?? TrainDisruptionsData(Status: 1, Message: [msg(Content: "", CreatedDate: "")], AffectedSegments: [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")])
        self.isFirstOpen = userDefaults.object(forKey: "isFirstOpen") as? Bool ?? true
        self.lastUpdatedBus = userDefaults.object(forKey: "lastUpdatedBus") as? Date ?? Date.now
        let carparkAvailabilityDat = userDefaults.data(forKey: "carparkAvailability")
        if let carparkAvailabilityDat = carparkAvailabilityDat {
            let parkingAvail = try? decoder.decode([CarparkAvailabilityMData].self, from: carparkAvailabilityDat)
            self.carparkAvailability = parkingAvail ?? [CarparkAvailabilityMData(CarParkID: "", Area: "", Development: "", Location: "", AvailableLots: 0, LotType: "", Agency: "")]
        } else {
            self.carparkAvailability = [CarparkAvailabilityMData(CarParkID: "", Area: "", Development: "", Location: "", AvailableLots: 0, LotType: "", Agency: "")]
        }
    }
}
