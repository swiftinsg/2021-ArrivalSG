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
    
    @State var isDefaultsExpanded: Bool = false
    //@State var disruptionData: TrainDisruptionsData
    @State var disruptionData: TrainDisruptionsData = TrainDisruptionsData(Status: 2, Message: [msg(Content: "Hello Messahe", CreatedDate: "123 Time")], AffectedSegments: [affectedSeg(Line: "EAST", Direction: "WONDERLAND", Stations: "1,2,3", FreePublicBus: "No Bus", FreeMRTShuttle: "No Shuttle", MRTShuttleDirection: "No Direction"),affectedSeg(Line: "WEST", Direction: "NOWONDERLAND", Stations: "0,2,5", FreePublicBus: "Magiv Bus", FreeMRTShuttle: "No Shuttle", MRTShuttleDirection: "No Direction")])
    
    var body: some View {

        VStack {
            Text("Train Disruptions")
                .bold()
                .font(.largeTitle)
                .frame(alignment: .leading)
            
            if isDisruptions{
                VStack{
                    ForEach($disruptionData.AffectedSegments){ $trainDataSpecifc in
                        DisclosureGroup(isExpanded:$isDefaultsExpanded){
                            Text("Free Public Buses Avalable at")
                                .bold()
                            Text(trainDataSpecifc.FreePublicBus)
                                .bold()
                                .padding()
                            Text("Free MRT Shuttle Avalable at")
                                .bold()
                            Text(trainDataSpecifc.FreeMRTShuttle)
                                .bold()
                                .padding()
                        } label: {
                            Text(trainDataSpecifc.Line)
                            
                        }
                    }.padding()
                }
                    
            }else{
                Text("There are no Train Disruptions")
            }
            
        }.onAppear {
            let disruptionData = userSettings.trainDisruptions
            if disruptionData.Status == 1 {
                isDisruptions = false
            }else{
                isDisruptions = true
            }
        }

    }
}



