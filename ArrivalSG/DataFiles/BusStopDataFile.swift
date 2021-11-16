//
//  BusStopData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation
import SwiftUI

class BusStopsDataFile: ObservableObject {
    
    @Published var busStopsData: [BusStopsData] = []
    
    func getArchiveURL() -> URL {
        let plistName = "busStopData.plist"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        return documentsDirectory.appendingPathComponent(plistName)
    }
    
    func save() {
        let archiveURL = getArchiveURL()
        let propertyListEncoder = PropertyListEncoder()
        let encodedFriends = try? propertyListEncoder.encode(busStopsData)
        try? encodedFriends?.write(to: archiveURL, options: .noFileProtection)
    }
    
    func load() {
        let archiveURL = getArchiveURL()
        let propertyListDecoder = PropertyListDecoder()
        
        var finalBusStopData: [BusStopsData]!
        
        if let retrievedBusStopData = try? Data(contentsOf: archiveURL),
           let decodedData = try? propertyListDecoder.decode(Array<BusStopsData>.self, from: retrievedBusStopData) {
            finalBusStopData = decodedData
        }
    }
}
