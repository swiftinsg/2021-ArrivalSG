//
//  TabBar.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI
import MapKit

struct TabBar: View {
    
    private enum Tabs: Hashable {
        case bus
        case train
        case traindisruption
    }
    
    @State private var selectedTab: Tabs = .bus
    @ObservedObject var userSettings = UserSettings()
    
    func prepareDataReload() async throws {
        var busStopArr:[Int] = []
        var busStopLoc:[[String:Any]] = [[:]]
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var fetchStops = FetchBusStops()
        @ObservedObject var fetchStopData = FetchBuses()
        @ObservedObject var carparkAvail = CarparkAvailability()
        userSettings.isFirstOpen = false
        
        // Fetch Bus Stops
        try await fetchStops.fetchBusStops()
        let stops = fetchStops.stops
        busStopLoc.removeAll()
        
        for i in 0..<stops!.count {
            busStopArr.append(Int(stops![i].BusStopCode) ?? 0)
            busStopLoc.append(["Name": stops![i].Description,"RoadName": stops![i].RoadName, "BusStopCode": String(stops![i].BusStopCode), "Latitude": String(stops![i].Latitude), "Longitude": String(stops![i].Longitude)])
        }
        
        userSettings.sgBusStopLoc = busStopLoc
        userSettings.sgBusStops = busStopArr
        
        // Fetch Carpark Availability
        try await carparkAvail.fetchCarparkAvailability()
        userSettings.carparkAvailability = carparkAvail.carparkAvailability ?? [CarparkAvailabilityMData(CarParkID: "", Area: "", Development: "", Location: "", AvailableLots: 0, LotType: "", Agency: "")]
        
        reloadData()
        
        func reloadData() {
            @ObservedObject var userSettings = UserSettings()
            let data = userSettings.sgBusStops
            var dataa:[[String:Any]] = []
            
            for i in 0...data.count-1 {
                fetchStopData.fetchBuses(BusStopCode: data[i]) { result in
                    switch result {
                    case .success(let stop):
                        dataa.append(stop)
                    case .failure(let error):
                        print("Error in Getting Bus Stops: \(error)")
                    }
                }
            }
            userSettings.busStopData = dataa
        }
    }
    
    func handleTrainDisruptions() {
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var getTrainDisruptions = TrainDisruptions()
        
        getTrainDisruptions.fetchDisruptions() { result in
            switch result {
            case .success(let disruptions):
                userSettings.trainDisruptions = disruptions
            case .failure(let error):
                print("Error in Getting Bus Stops: \(error)")
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tag(0)
                .tabItem {
                    Text("Bus")
                    Image(systemName: "bus.fill")
                }
                .task {
                    if (userSettings.isFirstOpen) {
                        print("First Open")
                        try? await prepareDataReload()
                        userSettings.isFirstOpen = false
                    }
                }
                .preferredColorScheme(.light)
            TrainMap()
                .tag(1)
                .tabItem {
                    Text("Train")
                    Image(systemName: "tram.fill")
                }
                .preferredColorScheme(.light)
            TrainDisruption()
                .tag(2)
                .tabItem {
                    Text("Train Disruptions")
                    Image(systemName: "xmark.octagon")
                }
                .preferredColorScheme(.light)
        }
    }
}
