//
//  FetchData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import MapKit

class FetchBusStops: ObservableObject {
    @Published var stops: [BusStopLoc]?
    var stopsData:[BusStopLoc] = []
    var stopsDataDouble:[BusStopLocDouble] = []
    let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String
    
    func fetchBusStops() async throws -> Void {
        for i in 0...11 {
            let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(i*500)")! // Link to API
            var request = URLRequest(url: API_ENDPOINT)
            request.addValue(apiKey!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            if let res = try? decoder.decode(BusStops.self, from: data) {
                if (res.value != []) {
                    for i in 0...500 {
                        self.stopsData.append(res.value[i])
                    }
                } else {
                    self.stops = self.stopsData
                    break
                }
            } else {
                let res = BusStops(value: (try? decoder.decode(BusStopsDouble.self, from: data).value.map {
                    $0.convert()
                })!)
                if (res.value != []) {
                    for i in 0..<res.value.count {
                        self.stopsData.append(res.value[i])
                    }
                } else {
                    self.stops = self.stopsData
                    break
                }
            }
        }
    }
}
    
