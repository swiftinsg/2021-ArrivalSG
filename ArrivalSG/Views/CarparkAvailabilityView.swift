//
//  CarparkAvailabilityView.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 17/3/22.
//

import SwiftUI
import Snap
import CoreData
import MapKit
import SwiftDate

struct CarparkAvailabilityView: View {
    @ObservedObject var fetchStops = FetchBusStops()
    @ObservedObject var userSettings = UserSettings()
    
    // Variables
    @State var locationModel = LocationViewModel()
    @State public var currentlySelected = "Location"
    @State var centreCoordinate = CLLocationCoordinate2D()
    @State var isShowCarparks = false
    @State var isShowNewStops = false // VALUE IS A CONSTANT FALSE. DO NOT UPDATE VALUE2
    @State var shownBusStops: [[String:String]] = [] // VALUE IS A CONSTANT FALSE. DO NOT UPDATE VALUE
    @State var shownCarparks: [CarparkAvailabilityMData] = []
    @State var isDefaultsExpanded = [false]
    
    @State var refresh: Bool = false
    
    @State var reloadTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    init() {
        locationModel.checkIfLocationEnabled()
    }
    
    var body: some View {
        // Map
        GeometryReader { geometry in
            ZStack {
                MapView(centreCoordinate: $centreCoordinate, showNewStops: $isShowNewStops, showCarparks: $isShowCarparks, shownBusStops: $shownBusStops, shownCarparks: $shownCarparks)
                    .edgesIgnoringSafeArea(.all)
                    .accentColor(Color(.systemPink))
                    .onChange(of: shownBusStops) { _ in
                        
                    }
                
                SnapDrawer(large: .paddingToTop(150), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                    ScrollView {
                        VStack {
                            if (shownCarparks.count != 0) {
                                ListCarparks(carparkData: shownCarparks)
                                    .padding(.horizontal)
                            } else {
                                Text("Click 'Reload' in an area with Bus Stops!")
                            }
                        }
                        .onChange(of: shownCarparks){ _ in
                            var x = [false]
                            for _ in 0..<shownCarparks.count{
                                x.append(false)
                            }
                            isDefaultsExpanded = x
                        }
                        
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        CarparkOverlayControls(isShowCarparks: $isShowCarparks)
                        Spacer()
                            .offset(y: geometry.safeAreaInsets.top)
                    }
                    Spacer()
                }
            }.alert(isPresented: $locationModel.isAlertPresented) {
                Alert(title: Text(locationModel.locationAuthError[0]), message: Text(locationModel.locationAuthError[1]), dismissButton: .destructive(Text("Ok")))
            }
            .onReceive(reloadTimer) { _ in
                refresh.toggle()
                self.reloadTimer.upstream.connect().cancel()
            }
        }
    }
}

struct CarparkOverlayControls: View {    
    @Binding var isShowCarparks: Bool
    
    var body: some View {
        // Buttons in the top right hand corner
        VStack {
            Button {
                isShowCarparks = true
            } label: {
                Image(systemName: "gobackward")
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(Color(uiColor:  .white))
            .cornerRadius(8)
        }
        .padding()
    }
}

struct ListCarparks: View {
    let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect() // Carpark Availability will update every 2 minutes
    var carparkData: [CarparkAvailabilityMData]
    
    struct formattedData: Codable, Hashable {
        var CarParkID: String
        var Area: String
        var Development: String
        var AvailableLots: [String:String]
        var LotType: String
        var Agency: String
    }
    
    @State var formattedCarparkData: [formattedData] = []
    
    func reloadData() async throws {
        @ObservedObject var carparkAvail = CarparkAvailability()
        @ObservedObject var userSettings = UserSettings()
        try await carparkAvail.fetchCarparkAvailability()
        userSettings.carparkAvailability = carparkAvail.carparkAvailability ?? [CarparkAvailabilityMData(CarParkID: "", Area: "", Development: "", Location: "", AvailableLots: 0, LotType: "", Agency: "")]
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(formattedCarparkData, id: \.self) { carData in
                Text("\(carData.Development) - \(carData.CarParkID as? String ?? "")")
                    .font(.system(size: 19))
                    .foregroundColor(Color(.label))
                    .bold()
                VStack(alignment: .leading) {
                    Text("Car Lots: \(carData.AvailableLots["C"] ?? "0")")
                        .foregroundColor(Color(.label))
                        .opacity(0.8)
                    Text("Heavy Lots: \(carData.AvailableLots["H"] ?? "0")")
                        .foregroundColor(Color(.label))
                        .opacity(0.8)
                    Text("Motorcycle Lots: \(carData.AvailableLots["Y"] ?? "0")")
                        .foregroundColor(Color(.label))
                        .opacity(0.8)
                }
                Divider()
            }
        }
        .onReceive(timer) { _ in
            Task {
                try? await reloadData()
            }
        }
        .onAppear {
            let data = carparkData
            var completedID:[String] = []
            for i in 0..<carparkData.count {
                if !completedID.contains(carparkData[i].CarParkID)  {
                    var temp: formattedData = formattedData(CarParkID: "", Area: "", Development: "", AvailableLots: [:], LotType: "", Agency: "")
                    var availLot = ["C": "0", "H": "0", "Y": "0"]
                    temp.CarParkID = data[i].CarParkID
                    temp.Agency = data[i].Agency
                    temp.Development = data[i].Development
                    temp.Area = data[i].Area
                    availLot[data[i].LotType] = String(data[i].AvailableLots)
                    for j in 0..<data.count {
                        if data[i].CarParkID == data[j].CarParkID && data[i] != data[j] {
                            availLot[data[j].LotType] = String(data[j].AvailableLots)
                        }
                    }
                    temp.AvailableLots = availLot
                    completedID.append(data[i].CarParkID)
                    formattedCarparkData.append(temp)
                }
            }
        }
    }
}

struct CarparkAvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        CarparkAvailabilityView()
    }
}
