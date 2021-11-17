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
    var stopsData:[Any] = []
    var skipBy = 0
    
    func fetchBusStops() async throws -> Void {
        while true {
            let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(skipBy)")! // Link to API
            print(API_ENDPOINT)
            var request = URLRequest(url: API_ENDPOINT)
            request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderField: "AccountKey") // Getting API Key from Xcode Environment Values
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            if let res = try? decoder.decode(BusStops.self, from: data) {
                if (res.value != []) {
                    self.stopsData.append(res.value)
                    self.skipBy += 500
                } else {
                    self.stops! = self.stopsData as! [BusStopLoc]
                    break
                }
            }
        }
    }
    
//    func fetchBusStops(completion: @escaping (Result<[BusStopLoc], Error>) -> Void) {
//        while true {
//            let API_ENDPOINT = URL(string: "http://datamall2.mytransport.sg/ltaodataservice/BusStops?$skip=\(skipBy)")! // Link to API
//            print(API_ENDPOINT)
//            var request = URLRequest(url: API_ENDPOINT)
//            request.addValue(ProcessInfo.processInfo.environment["API_KEY"]!, forHTTPHeaderFiseld: "AccountKey") // Getting API Key from Xcode Environment Values
//            request.httpMethod = "GET"
//            let data = Data(contentsOf: <#T##URL#>)
//            URLSession.shared.dataTask(with: request) { data, response, error in // Make API Request
//                if let data = data { // Make sure Data != nil
//                    let decoder = JSONDecoder()
//                    if let res = try? decoder.decode(BusStops.self, from: data) {
//                        if (res.value != []) {
//                            self.stopsData.append(res.value)
//                            self.skipBy += 500
//                        } else {
//                            DispatchQueue.main.async {
//                                self.stops! = self.stopsData as! [BusStopLoc]
//                                return completion(.success(self.stops!))
//                            }
//                        }
//                    }
//                } else {
//                    fatalError("An Error has Occured")
//                }
//            }.resume()
//        }
//    }
}
    
