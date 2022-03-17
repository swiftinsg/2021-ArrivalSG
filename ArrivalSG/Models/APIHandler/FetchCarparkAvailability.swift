//
//  FetchCarparkAvailability.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/3/22.
//

import Foundation

class CarparkAvailability: ObservableObject {
    @Published var carparkAvailability: [CarparkAvailabilityMData]?
    var carparkData:[CarparkAvailabilityMData] = []
    
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
    
    func fetchCarparkAvailability() async throws -> Void {
        for i in 0...11 {
            let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/CarParkAvailabilityv2?$skip=\(i*500)")! // Link to API
            var request = URLRequest(url: API_ENDPOINT)
            request.addValue(apiKey, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            if let res = try? decoder.decode(CarparkAvailabilityData.self, from: data) {
                if (res.value != []) {
                    for i in 0..<res.value.count {
                        self.carparkData.append(res.value[i])
                    }
                } else {
                    self.carparkAvailability = self.carparkData
                    break
                }
            } else {
                print("Unable to Decode Data")
            }
        }
    }
}
