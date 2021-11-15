//
//  FetchData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

class FetchBusStops: ObservableObject {
    @Published var stops: BusStops?
    @Published var busStopCodes = []
    
    func fetchBusStops() {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops")!
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey")
        request.httpMethod = "GET"
        
        stops = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                DispatchQueue.main.async {
                    self.stops = try? decoder.decode(BusStops.self, from: data)
                }
            } else {
                fatalError("An Error has Occured")
            }
        }.resume()
    }
    
    
}
    
