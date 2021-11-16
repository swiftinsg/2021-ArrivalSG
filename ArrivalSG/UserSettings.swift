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
    
    @Published var isFirstOpen: Bool {
        didSet {
            userDefaults.set(busStopData, forKey: "isFirstOpen")
        }
    }
    
    init() {
        self.sgBusStops = userDefaults.object(forKey: "sgBusStops") as? [Int] ?? [0]
        self.busStopData = userDefaults.object(forKey: "busStopData") as? [[String:Any]] ?? []
        self.isFirstOpen = userDefaults.bool(forKey: "busStopData") as? Bool ?? true
    }
}
