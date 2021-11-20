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
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/TrainServiceAlerts")! // Link to API
        
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
        request.httpMethod = "GET"
                
        URLSession.shared.dataTask(with: request) { data, response, error in // Make API Request
            if let data = data { // Make sure Data != nil
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                        let status = json["Status"] as! Int
                        let affectedSeg = json["Affected Segments"] as? [affectedSeg] ?? [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")]
                        let msg = json["Message"] as? [msg] ?? [msg(Content: "", CreatedDate: "")]
                        self.disruptions = TrainDisruptionsData(Status: status, Message: msg, AffectedSegments: affectedSeg)
                        return completion(.success(self.disruptions!))
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
