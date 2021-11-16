//
//  TrainDisruption.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI

struct TrainDisruption: View {
    @ObservedObject var getBusStops = FetchBusStops()
    
    var body: some View {
        VStack {
            Text("Train Disruptions")
            if let stops = getBusStops.stops {
                Text("Stopssss")
                ForEach(stops.value, id: \.self) {
                    Text("\($0.BusStopCode)")
                }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
        }.onAppear{
//            getBusStops.fetchBusStops()
        }
    }
}

