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
    
    @State var isDefaultsExpanded = [false]
    @State var disruptionData: TrainDisruptionsData = TrainDisruptionsData(Status: 1, Message: [msg(Content: "", CreatedDate: "")], AffectedSegments: [affectedSeg(Line: "", Direction: "", Stations: "", FreePublicBus: "", FreeMRTShuttle: "", MRTShuttleDirection: "")])
//    @State var disruptionData: TrainDisruptionsData = TrainDisruptionsData(Status: 2, Message: [msg(Content: "1811hrs: EWL - Additional travelling time of 30 minutes between Paya Lebar and Pasir Ris stations due to a train fault at Paya Lebar station.", CreatedDate: "2017-12-11 18:12:06"),msg(Content: "1756hrs: NSL - No train service between Bishan and Woodlands stations towards Jurong East station due to a signal fault. Free bus shuttle are available at designated bus stops.", CreatedDate:"2017-12-11 17:56:50")], AffectedSegments: [affectedSeg(Line: "EWL", Direction: "Both", Stations: "EW8,EW7,EW6,EW5,EW4,EW3,EW2,EW1", FreePublicBus: "EW8, EW7,EW6,EW5, EW4, EW3, EW2, EWI", FreeMRTShuttle: "EW8,EW7,EW6,EW5,EW4,EWB,EW2,EW1", MRTShuttleDirection: "Both"),affectedSeg(Line: "NSL", Direction: "Jurong East", Stations: "NS17,NS16,NS15,NS14,NS13,NS11,NS10,NS9", FreePublicBus: "", FreeMRTShuttle: "NS16,NS15,NS14,NS13, NS11,NS10, N59", MRTShuttleDirection: "Jurong East")])// THIS IS FOR DEBUG
    
    let timer = Timer.publish(every: 600, on: .main, in: .common).autoconnect() // Update data every 10mins

    func findText(line: String) -> String{
        var messageContent = ""
        for i in 0..<(disruptionData.Message.count){
            let text = disruptionData.Message[i].Content
            let arrayResult = text.contains(line)
            if (arrayResult){
                messageContent = text
            }
        }
        return messageContent
    }
    
    func textCheck(text: String) -> String{
        var textToReturn = ""
        if text == "" {
            textToReturn = "None"
        } else{
            textToReturn = text
        }
        return textToReturn
    }
    
    func stationName(text: String) -> String{
        var textToReturn = ""
        let listItems = text.components(separatedBy: ",")
        textToReturn = "\(listItems[(listItems.count)-1]) to \(listItems[0])"
        return textToReturn
    }
    
    func fullName(line: String) -> String{
        let MRTDict = ["EWL" : "East-West Line", "TEL" : "Thomson-East Coast Line","NSL" : "North-South Line", "NEL" : "North East Line","DTL" : "Downtown Line", "CCL" : "Circle Line","BP" : "Bukit Panjang LRT","SK" : "Sengkang-Punggol LRT"]
        let textToReturn = MRTDict[line]!
        return textToReturn
    }
    
    var body: some View {
        VStack {
            Text("Train Disruptions")
                .bold()
                .font(.largeTitle)
                .frame(alignment: .leading)
            if isDisruptions {
                ScrollView {
                    VStack {
                        ForEach(0..<disruptionData.AffectedSegments.count, id: \.self) { i in
                            DisclosureGroup(isExpanded: $isDefaultsExpanded[i]) {
                                VStack(alignment: .leading) {
                                    VStack(alignment: .leading) {
                                        Text("Free Public Buses Available at")
                                            .bold()
                                        Text(textCheck(text: disruptionData.AffectedSegments[i].FreePublicBus))
                                    }.padding()
                                    VStack(alignment: .leading) {
                                        Text("Free MRT Shuttle Available at")
                                            .bold()
                                        Text(textCheck(text: disruptionData.AffectedSegments[i].FreeMRTShuttle))
                                    }.padding()
                                    VStack(alignment: .leading) {
                                        Text("Message from LTA")
                                            .bold()
                                        Text(textCheck(text: (findText(line: disruptionData.AffectedSegments[i].Line))))
                                    }.padding()
                                    HStack {
                                        Spacer()
                                        VStack {
                                            Text("Time: \(textCheck(text: (disruptionData.Message[i].CreatedDate)))")
                                                .font(.system(size: 15))
                                        }
                                        Spacer()
                                    }
                                }
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(stationName(text: disruptionData.AffectedSegments[i].Stations))
                                            .bold()
                                            .font(.title3)
                                        Text((fullName(line: disruptionData.AffectedSegments[i].Line)))
                                            .foregroundColor(SwiftUI.Color.white)
                                            .padding(3.0)
                                            .padding(.horizontal, 7.0)
                                            .background(Rectangle().fill(Color(disruptionData.AffectedSegments[i].Line)))
                                            .font(.system(size: 15))
                                            .cornerRadius(30)
                                    }
                                }
                            }.foregroundColor(.black)
                                .padding()

                            Divider()
                        }
                    }
                }
                    
            } else {
                VStack{
                    Text("There are no Train Disruptions")
                    if isMessage {
                        Text("Latest Updates")
                            .bold()
                            .font(.system(size: 25))
                            .padding()
                        ForEach(0..<disruptionData.Message.count, id: \.self) { i in
                            Text(disruptionData.Message[i].Content)
                            Text("Time: \(disruptionData.Message[i].CreatedDate)")
                            Spacer()
                        }
                    }
                }.padding()
            }
            
        }.onAppear {
            disruptionData = userSettings.trainDisruptions
            
            if disruptionData.Status == 1 {
                isDisruptions = false
                // This is for if there are no disruptions but have messages
                if disruptionData.Message.count > 0 && disruptionData.Message[0].Content != "" {
                    isMessage = true
                } else {
                    isMessage = false
                }
            } else {
                isDisruptions = true
                for _ in 0..<(disruptionData.AffectedSegments.count - 1) {
                    isDefaultsExpanded.append(false)
                }
            }
        }
        .onReceive(timer) { _ in
            @ObservedObject var userSettings = UserSettings()
            @ObservedObject var getTrainDisruptions = TrainDisruptions()
            
            getTrainDisruptions.fetchDisruptions() { result in
                switch result {
                case .success(let disruptions):
                    DispatchQueue.main.async {
                        userSettings.trainDisruptions = disruptions
                    }
                case .failure(let error):
                    print("Error in Getting Bus Stops: \(error)")
                }
            }
        }
    }
}
