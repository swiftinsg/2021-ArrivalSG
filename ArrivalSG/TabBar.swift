//
//  TabBar.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI

struct TabBar: View {
    
    private enum Tabs: Hashable {
        case bus
        case train
        case traindisruption
    }
    
    @State private var selectedTab: Tabs = .bus
    @ObservedObject var userSettings = UserSettings()
    
    func prepareDataReload() {
        var busStopArr:[Int] = []
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var fetchStops = FetchBusStops()
        @ObservedObject var fetchStopData = FetchBuses()
        
        fetchStops.fetchBusStops() { result in
            switch result {
            case .success(let stops):
                let val = stops.value
                for i in 0..<val.count {
                    busStopArr.append(Int(val[i].BusStopCode) ?? 0)
                }
                userSettings.sgBusStops = busStopArr
                reloadData()
            case .failure(let error):
                print("Error in Getting Bus Stops: \(error)")
            }
        }
        
        
        func reloadData() {
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
    
    init() {
        if (userSettings.isFirstOpen) {
            prepareDataReload()
            userSettings.isFirstOpen = false
        }
        
        handleTrainDisruptions()
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tag(0)
                .tabItem {
                    Text("Bus")
                    Image(systemName: "bus.fill")
                }
                .onAppear {
                    if (userSettings.isFirstOpen) {
                        prepareDataReload()
                        userSettings.isFirstOpen = false
                    }
                }
            TrainMap()
                .tag(1)
                .tabItem {
                    Text("Train")
                    Image(systemName: "tram.fill")
                }
            TrainDisruption()
                .tag(2)
                .tabItem {
                    Text("Train Disruptions")
                    Image(systemName: "xmark.octagon")
                }
        }
    }
}
