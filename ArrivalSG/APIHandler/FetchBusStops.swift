//
//  FetchData.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

class FetchBusStops: ObservableObject {
    @Published var stops: BusStops?
    
    func fetchBusStops(completion: @escaping (Result<BusStops, Error>) -> Void) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops")! // Link to API
        
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
        request.httpMethod = "GET"
        
        stops = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in // Make API Request
            if let data = data { // Make sure Data != nil
                let decoder = JSONDecoder()
                DispatchQueue.main.async {
                    self.stops = try? decoder.decode(BusStops.self, from: data) // Decode Data, Return Completion
                    return completion(.success(self.stops!))
                }
            } else {
                fatalError("An Error has Occured")
            }
        }.resume()
    }
}
    
