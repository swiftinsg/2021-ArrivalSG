//
//  UserSettings.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    let userDefaults = UserDefaults.standard
    
    @Published var sgBusStops: [Int] {
        didSet {
            print("Saving to UserDefaults")
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
            userDefaults.set(busStopData, forKey: "sgBusStopLoc")
        }
    }
    
    @Published var trainDisruptions: TrainDisruptionsData {
        didSet {
            userDefaults.set(trainDisruptions, forKey: "trainDisruptions")
        }
    }
    
    @Published var isFirstOpen: Bool {
        didSet {
            userDefaults.set(busStopData, forKey: "isFirstOpen")
        }
    }
    
    @Published var showStopRadius: Double {
        didSet {
            userDefaults.set(showStopRadius, forKey: "showStopRadius")
        }
    }
    
    init() {
        self.sgBusStops = userDefaults.object(forKey: "sgBusStops") as? [Int] ?? [0]
        self.busStopData = userDefaults.object(forKey: "busStopData") as? [[String:Any]] ?? [[:]]
        self.sgBusStopLoc = userDefaults.object(forKey: "sgBusStopLoc") as? [[String:Any]] ?? [[:]]
        self.trainDisruptions = userDefaults.object(forKey: "trainDisruptions") as? TrainDisruptionsData ?? TrainDisruptionsData(Status: 1, Message: [msg(Content: "", CreatedDate: "")], AffectedSegments: [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")])
        self.isFirstOpen = userDefaults.bool(forKey: "busStopData") as? Bool ?? true
        self.showStopRadius = userDefaults.double(forKey: "showStopRadius") as? Double ?? 3.0
    }
}
