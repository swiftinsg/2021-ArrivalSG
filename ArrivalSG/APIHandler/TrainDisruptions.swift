//
//  TrainDisruptions.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation

class TrainDisruptions: ObservableObject {
    @Published var disruptions: TrainDisruptionsData?
    
    func fetchDisruptions(completion: @escaping (Result<TrainDisruptionsData, Error>) -> Void) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops")! // Link to API
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
        request.httpMethod = "GET"
        
        disruptions = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in // Make API Request
            if let data = data { // Make sure Data != nil
                let decoder = JSONDecoder()
                DispatchQueue.main.async {
                    self.disruptions = try? decoder.decode(TrainDisruptionsData.self, from: data) // Decode Data, Return Completion
                    return completion(.success(self.disruptions ?? TrainDisruptionsData(value: [dataVal(Status: 1, Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "", Message: "")])))
                }
            } else {
                fatalError("An Error has Occured")
            }
        }.resume()
    }
}
