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
    @State var isMessage = false
    
    @State var isDefaultsExpanded = []
    //@State var disruptionData: TrainDisruptionsData
    @State var disruptionData: TrainDisruptionsData = TrainDisruptionsData(Status: 2, Message: [msg(Content: "1811hrs: EWL - Additional travelling time of 30 minutes between Paya Lebar and Pasir Ris stations due to a train fault at Paya Lebar station.", CreatedDate: "2017-12-11 18:12:06"),msg(Content: "1756hrs: NSL - No train service between Bishan and Woodlands stations towards Jurong East station due to a signal fault. Free bus shuttle are available at designated bus stops.", CreatedDate:"2017-12-11 17:56:50")], AffectedSegments: [affectedSeg(Line: "EWL", Direction: "Both", Stations: "EW8, EW7, EW6,EW5,EW4, EW3, EW2, EW1", FreePublicBus: "EW8, EW7,EW6,EW5, EW4, EW3, EW2, EWI", FreeMRTShuttle: "EW8,EW7,EW6,EW5,EW4,EWB,EW2,EW1", MRTShuttleDirection: "Both"),affectedSeg(Line: "NSL", Direction: "Jurong East", Stations: "NS17,NS16,NS15,NS14,NS13,NS11,NS10,NS9", FreePublicBus: "", FreeMRTShuttle: "NS16,NS15,NS14,NS13, NS11,NS10, N59", MRTShuttleDirection: "Jurong East")])// THIS IS FOR DEBUG
    
    extension String {
        var boolValue: Bool { (self as NSString).boolValue }
    }
    func findText(line: String) -> String{
        var messageContent = ""
        for i in 0..<(disruptionData.Message.count){
            let text = disruptionData.Message[i].Content
            let arrayResult = text.contains(line)
            if (arrayResult){
                messageContent = text
            }
        }
        print(messageContent)
        return messageContent
    }
    func textCheck(text: String) -> String{
        var textToReturn = ""
        if text == ""{
            textToReturn = "None"
        }else{
            textToReturn = text
        }
        return textToReturn
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
                            DisclosureGroup(isExpanded: $isDefaultsExpanded[i].boolValue)){
                                VStack(alignment: .leading){
                                    VStack(alignment: .leading){
                                        Text("Free Public Buses Available at")
                                            .bold()
                                        Text(textCheck(text: disruptionData.AffectedSegments[i].FreePublicBus))
                                    }.padding()
                                    VStack(alignment: .leading){
                                        Text("Free MRT Shuttle Available at")
                                            .bold()
                                        Text(textCheck(text: disruptionData.AffectedSegments[i].FreeMRTShuttle))
                                    }.padding()
                                    VStack(alignment: .leading){
                                        Text("Message from LTA")
                                            .bold()
                                        Text(textCheck(text: (findText(line: disruptionData.AffectedSegments[i].Line))))
                                    }.padding()
                                    HStack{
                                        Spacer()
                                        VStack{
                                            Text("Time: \(textCheck(text: (disruptionData.Message[i].CreatedDate)))")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                    }
                                }
                            } label: {
                                HStack{
                                    VStack{
                                        Text(disruptionData.AffectedSegments[i].Line)
                                            .bold()
                                        Text("Affected Stations: \(disruptionData.AffectedSegments[i].Stations)")
                                            .font(.system(size: 15))
                                    }
                                }.padding(.horizontal)
                            }.foregroundColor(.black)
                        }
                    }
                }
                    
            }else{
                VStack{
                    Text("There are no Train Disruptions")
                    if isMessage{
                        Text("Latest News")
                            .bold()
                            .font(.system(size: 25))
                            .padding()
                        Text(disruptionData.Message[0].Content)
                        Text("Time: \(disruptionData.Message[0].CreatedDate)")
                    }
                }.padding()
            }
            
        }.onAppear {
            //let disruptionData = userSettings.trainDisruptions
            if disruptionData.Status == 1 {
                isDisruptions = false
                // This is for if there are no disruptions but have messages
                if disruptionData.Message.count < 1{
                    isMessage = false
                }else{
                    isMessage = true
                }
                    
            }else{isDefaultsExpanded
                isDisruptions = true
                ForEach(0..<disruptionData.AffectedSegments.count, id: \.self) { i in
                    isDefaultsExpanded[i] = false
            }
        }

    }
}



