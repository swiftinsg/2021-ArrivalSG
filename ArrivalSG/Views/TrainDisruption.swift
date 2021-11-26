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
    @State var disruptionData: TrainDisruptionsData = TrainDisruptionsData(Status: 2, Message: [msg(Content: "WEST - Hello Messahe", CreatedDate: "123 Time"),msg(Content: "EAST - Hello Messahe", CreatedDate: "123 Time")], AffectedSegments: [affectedSeg(Line: "EAST", Direction: "WONDERLAND", Stations: "1,2,3", FreePublicBus: "No Bus", FreeMRTShuttle: "No Shuttle", MRTShuttleDirection: "No Direction"),affectedSeg(Line: "WEST", Direction: "NOWONDERLAND", Stations: "0,2,5", FreePublicBus: "Magiv Bus", FreeMRTShuttle: "No Shuttle", MRTShuttleDirection: "No Direction")]) // THIS IS FOR DEBUG
    func findText(line: String) -> String{
        var messageContent = ""
        for i in 0..<(disruptionData.Message.count){
        //ForEach(0..<disruptionData.Message.count, id: \.self) { i in
            let text = disruptionData.Message[i].Content
            let arrayResult = text.contains(line)
            if (arrayResult){
                messageContent = text
            }
        }
        print(messageContent)
        return messageContent
    }
    
    var body: some View {

        VStack {
            Text("Train Disruptions")
                .bold()
                .font(.largeTitle)
                .frame(alignment: .leading)
            
            if isDisruptions{
                ScrollView{
                    VStack{
                        ForEach(0..<disruptionData.AffectedSegments.count, id: \.self) { i in
                            DisclosureGroup(isExpanded:$isDefaultsExpanded){
                                VStack(alignment: .leading){
                                    VStack(alignment: .leading){
                                        Text("Free Public Buses Avalable at")
                                            .bold()
                                        Text(disruptionData.AffectedSegments[i].FreePublicBus)
                                            
                                    }.padding()
                                    VStack{
                                        Text("Free MRT Shuttle Avalable at")
                                            .bold()
                                        Text(disruptionData.AffectedSegments[i].FreeMRTShuttle)
                                        
                                    }.padding()
                                    VStack{
                                        Text("Message from LTA")
                                            .bold()
                                        Text(findText(line: disruptionData.AffectedSegments[i].Line))
                                        Text("Time: \(disruptionData.Message[i].Content)")
                                    }.padding()
                                }
                            } label: {
                                VStack{
                                    Text(disruptionData.AffectedSegments[i].Line)
                                        .bold()
                                    Text("Hello Wolrd")
                                }
                            }
                        }.padding()
                    }
                }
                    
            }else{
                Text("There are no Train Disruptions")
            }
            
        }.onAppear {
            //let disruptionData = userSettings.trainDisruptions
            if disruptionData.Status == 1 {
                isDisruptions = false
            }else{
                isDisruptions = true
            }
        }

    }
}



