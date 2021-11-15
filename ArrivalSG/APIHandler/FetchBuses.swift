//
//  FetchBuses.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

class FetchBuses: ObservableObject {
    @Published var stopsData: BusStopsData?
    
    func fetchBusStops(BusStopCode: Int) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(BusStopCode)")!
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey")
        
        stopsData = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                DispatchQueue.main.async {
                    self.stopsData = try? decoder.decode(BusStopsData.self, from: data)
                }
            }
        }.resume()
    }
}
