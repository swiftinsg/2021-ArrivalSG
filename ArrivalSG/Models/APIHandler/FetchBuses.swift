//
//  FetchBuses.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation

class FetchBuses: ObservableObject {
    @Published var stopsData: [String: Any] = [:]
    var apiKey: String {
      get {
        // 1
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
          fatalError("Couldn't find file 'Secrets.plist'.")
        }
        // 2
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'Secrets.plist'.")
        }
        return value
      }
    }
    func fetchBuses(BusStopCode: Int, completion: @escaping (Result<[String:Any], Error>) -> Void) {
        let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusArrivalv2?BusStopCode=\(String(BusStopCode))")!
         
        var request = URLRequest(url: API_ENDPOINT)
        request.addValue(apiKey, forHTTPHeaderField: "AccountKey")
        request.httpMethod = "GET"
                
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.stopsData = ["BusStopCode": json["BusStopCode"] as? String, "Services": json["Services"] as? [[String:Any]] ?? []]
                        return completion(.success(self.stopsData))
                    }
                } catch let error as NSError {
                    print("Failed to Load: \(error.localizedDescription)")
                }
            } else {
                return completion(.failure(error!))
            }
        }.resume()
    }
}
