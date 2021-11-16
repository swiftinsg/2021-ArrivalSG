//
//  BusStopData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation
import SwiftUI

// Will fix later
//class BusStopsDataFile: ObservableObject {
//    
//    @Published var busStopsData: [[String: Any]] = [[:]]
//    
//    func getArchiveURL() -> URL {
//        let plistName = "busStopData.plist"
//        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        
//        return documentsDirectory.appendingPathComponent(plistName)
//    }
//    
//    func save() {
//        let archiveURL = getArchiveURL()
//        let encoder = JSONEncoder()
//        let encodedData = try? encoder.encode(busStopsData)
//        try? encodedData?.write(to: archiveURL, options: .noFileProtection)
//    }
//    
//    func load() {
//        let archiveURL = getArchiveURL()
//        let propertyListDecoder = PropertyListDecoder()
//        
//        var finalBusStopData: [[String: Any]] = [:]
//        
//        if let retrievedBusStopData = try? Data(contentsOf: archiveURL),
//           let decodedData = try? propertyListDecoder.decode(Array<[String: Any]>.self, from: retrievedBusStopData) {
//            finalBusStopData = decodedData
//        }
//    }
//}
