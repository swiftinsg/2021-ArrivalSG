//
//  TrainDisruption.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI

struct TrainDisruption: View {
    @ObservedObject var fetchStops = FetchBusStops()
    @ObservedObject var userSettings = UserSettings()
    @State var isDisruptions = false
    
    var body: some View {

        VStack {
            Text("Train Disruptions")
                .bold()
                .font(.largeTitle)
                .frame(alignment: .leading)
            if isDisruptions{
                // If yes
                Text("There is a Train Disruptions as of right now")
            }else{
                // if no
                Text("There are no Train Disruptions")
            }
            
        }.onAppear{
            let disruptionData = userSettings.trainDisruptions
            print(disruptionData)
            if disruptionData.Status as! Int == 1{
                isDisruptions = false
            }else{
                isDisruptions = true
            }
        }
    }
}

