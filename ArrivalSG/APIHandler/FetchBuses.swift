//
//  FetchBuses.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import MapKit

class FetchBuses: ObservableObject {
    @Published var stopsData: BusStopsData?
    
    func fetchBuses(BusStopCode: Int, completion: @escaping (Result<BusStopsData, Error>) -> Void) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(String(BusStopCode))")!
         
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey")
        request.httpMethod = "GET"
        
        stopsData = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        print(json)
                        self.stopsData = BusStopsData(BusStopCode: (json["BusStopCode"] as? Int)!, Services: (json["Services"] as? [BusStop])!)
                    }
                } catch let error as NSError {
                    print("Failed to Load: \(error.localizedDescription)")
                }
//                DispatchQueue.main.async {
//                    self.stopsData = try? decoder.decode(BusStopsData.self, from: data)
//                    return completion(.success(self.stopsData!))
//                }
            } else {
                return completion(.failure(error!))
            }
        }.resume()
    }
}
