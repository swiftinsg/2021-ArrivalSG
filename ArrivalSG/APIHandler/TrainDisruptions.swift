//
//  TrainDisruptions.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation

class TrainDisruptions: ObservableObject {
    @Published var disruptions: [String: Any] = [:]
    
    func fetchDisruptions(completion: @escaping (Result<[String:Any], Error>) -> Void) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops")! // Link to API
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
        request.httpMethod = "GET"
                
        URLSession.shared.dataTask(with: request) { data, response, error in // Make API Request
            if let data = data { // Make sure Data != nil
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        self.disruptions = ["Status": json["Status"] ?? 1, "Affected Segments": json["Affected Segments"] as?  [[String:String]] ?? [["Line": "", "Direction": "", "Stations": "", "FreePublicBus": "", "FreeMRTShuttle": "", "MRTShuttleDirection": ""]], "Message": json["Message"] as? [[String:String]] ?? [["Content": "", "CreatedData": ""]]]
                        return completion(.success(self.disruptions))
                    }
                } catch let error as NSError {
                    print("Failed to Load: \(error.localizedDescription)")
                }
            } else {
                fatalError("An Error has Occured")
            }
        }.resume()
    }
}
