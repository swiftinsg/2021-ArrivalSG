//
//  ContentView.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//
import SwiftUI
import Snap
import CoreData
import MapKit

struct ContentView: View {
    @ObservedObject var fetchStops = FetchBusStops()
    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var shownStops = ShownStops()
    
    // Variables
    @State var locationModel = LocationViewModel()
    @State public var currentlySelected = "Location"
    @State var centreCoordinate = CLLocationCoordinate2D()
    @State var showStopRadius = 3 // 3km is default
    @State var isSettingsOpen = false
    @State var currLocationOpen = true
    @State var favouritedOpen = false
    @State var isShowNewStops = false
    @State var shownBusStops: [Int] = []
    
    var body: some View {
        // Map
        GeometryReader { geometry in
            ZStack {
                MapView(centreCoordinate: $centreCoordinate, showNewStops: $isShowNewStops)
                    .edgesIgnoringSafeArea(.all)
                    .accentColor(Color(.systemPink))
                
                SnapDrawer(large: .paddingToTop(150), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                    if (favouritedOpen) {
                        FavouritedScreen()
                    }
                    
                    if (currLocationOpen) {
                        CurrLocationScreen()
                    }
                }
                
                if (isSettingsOpen) {
                    SettingsPopup(showStopRadius: $showStopRadius)
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        OverlayControls(isSettingsOpen: $isSettingsOpen, currLocationOpen: $currLocationOpen, favouritedOpen: $favouritedOpen, isShowNewStops: $isShowNewStops)
                        Spacer()
                            .offset(y: geometry.safeAreaInsets.top)
                    }
                    Spacer()
                }
            }.alert(isPresented: $locationModel.isAlertPresented) {
                Alert(title: Text(locationModel.locationAuthError[0]), message: Text(locationModel.locationAuthError[1]), dismissButton: .destructive(Text("Ok")))
            }
        }
    }
}

struct OverlayControls: View {
    @ObservedObject var showStops = ShownStops()

    @Binding var isSettingsOpen: Bool
    @Binding var currLocationOpen: Bool
    @Binding var favouritedOpen: Bool
    @Binding var isShowNewStops: Bool
    
    var body: some View {
        // Buttons in the top right hand corner
        VStack {
            VStack(spacing: 15) {
                Button {
                    if (currLocationOpen == false) {
                        currLocationOpen = true
                        favouritedOpen = false
                    }
                } label: {
                    Image(systemName: "location")
                }
                Divider()
                Button {
                    if (favouritedOpen == false) {
                        favouritedOpen = true
                        currLocationOpen = false
                    }
                } label: {
                    Image(systemName: "heart")
                }
            }
            .frame(width: 50)
            .padding(.vertical, 12)
            .background(Color(uiColor:  .white))
            .cornerRadius(8)
            
            Button {
                isSettingsOpen.toggle()
            } label: {
                Image(systemName: "gear")
            }
                .frame(width: 50)
                .padding(.vertical, 12)
                .background(Color(uiColor:  .white))
                .cornerRadius(8)
            
            Button {
                isShowNewStops = true
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

struct SettingsPopup: View {
    @Binding var showStopRadius:Int
    @State var infoText: String = ""
    @State var buttonDisabled: Bool = false
    
    var body: some View {
        // Temp UI
        VStack(alignment: .center, spacing: 3) {
            Text("Settings")
                .bold()
                .font(.title)
                .foregroundColor(.black)
                .padding()
            VStack {
                Button {
                    Task {
                        try? await prepareDataReload()
                    }
                } label: {
                    Text("Reload Bus Data")
                }
                    .padding()
                    .foregroundColor(.white)
                    .background(.cyan)
                    .cornerRadius(5)
                    .disabled(buttonDisabled == true)
                Text(infoText)
            }
            
        }
        .padding()
        .background(.white)
        .cornerRadius(5)
        
    }
    
    func prepareDataReload() async throws {
        infoText = "Loading Data..."
        buttonDisabled = true
        var busStopArr:[Int] = []
        var busStopLoc:[[String:Any]] = []
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var fetchStops = FetchBusStops()
        @ObservedObject var fetchStopData = FetchBuses()
        
        try await fetchStops.fetchBusStops()
        let stops = fetchStops.stops
                
        for i in 0..<stops!.count {
            busStopArr.append(Int(stops![i].BusStopCode) ?? 0)
            busStopLoc.append(["Name": stops![i].Description,"BusStopCode": Int(stops![i].BusStopCode), "Latitude": Double(stops![i].Latitude), "Longitude": Double(stops![i].Longitude)])
        }
        
        userSettings.sgBusStopLoc = busStopLoc
        userSettings.sgBusStops = busStopArr
        reloadData()
        
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
            print(dataa)
            userSettings.busStopData = dataa
            infoText = "Done!"
        }
    }
}

struct FavouritedScreen: View {
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        VStack {
            if (userSettings.favouritedBusStops.count == 0) {
                Text("You haven't favourited any Bus Stops!")
            } else {
                ScrollView {
                    Text("Favourited")
                }
            }
        }
    }
}

struct CurrLocationScreen: View {
    @ObservedObject var userSettings = UserSettings()
    
    var body: some View {
        VStack {
            Text("Current Location")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
