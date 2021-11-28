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
    @State var shownBusStops: [[String:String]] = []
    
    var body: some View {
        // Map
        GeometryReader { geometry in
            ZStack {
                MapView(centreCoordinate: $centreCoordinate, showNewStops: $isShowNewStops, shownBusStops: $shownBusStops)
                    .edgesIgnoringSafeArea(.all)
                    .accentColor(Color(.systemPink))
                    .onChange(of: shownBusStops) { _ in
                        
                    }
                
                SnapDrawer(large: .paddingToTop(150), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                    if (favouritedOpen) {
                        FavouritedScreen(shownBusStops: $shownBusStops)
                    }
                    
                    if (currLocationOpen) {
                        CurrLocationScreen(shownBusStops: $shownBusStops)
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
        print(stops)
        for i in 0..<stops!.count {
            busStopArr.append(Int(stops![i].BusStopCode) ?? 0)
            busStopLoc.append(["Name": stops![i].Description,"RoadName": stops![i].RoadName, "BusStopCode": String(stops![i].BusStopCode), "Latitude": String(stops![i].Latitude), "Longitude": String(stops![i].Longitude)])
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
            userSettings.busStopData = dataa
            infoText = "Done!"
        }
    }
}

struct FavouritedScreen: View {
    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var shownStops = ShownStops()
    @ObservedObject var fetchStopData = FetchBuses()
    
    @Binding var shownBusStops: [[String:String]]
    @State var busData:[[String:Any]] = []
    @State var isDefaultsExpanded = [false]
    
    let timer = Timer.publish(every: 55, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            ForEach(0..<userSettings.favouritedBusStops.count, id: \.self) { i in
                DisclosureGroup(isExpanded: $isDefaultsExpanded[i]) {
                    VStack{
                        Text("hello")
                    }
                } label: {
                    Text("S")
                }.foregroundColor(.black)
                    .padding()
                Divider()
                Spacer()
            }
        }.onAppear{
            print(userSettings.favouritedBusStops)
            print(userSettings.favouritedBusStops.count)
            if (userSettings.favouritedBusStops.count == 0) || (userSettings.favouritedBusStops.count == 1) {
                
            } else {
                for _ in (0..<(userSettings.favouritedBusStops.count)) {
                    isDefaultsExpanded.append(false)
                }
            }
        }
        .onReceive(timer) { _ in
            getNewData() // Recieve new data from API every 55s
        }
    }
    
    func getNewData() {
        for stopData in shownBusStops {
            fetchStopData.fetchBuses(BusStopCode: Int(stopData["BusStopCode"]!)!) { result in
                switch result {
                case .success(let stop):
                    DispatchQueue.main.async {
                        busData.append(stop)
                    }
                case .failure(let error):
                    print("Error in Getting Bus Stops: \(error)")
                }
            }
        }
    }
}


struct CurrLocationScreen: View {
    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var fetchStopData = FetchBuses()
    
    @State var isDefaultsExpanded = [false]
    @Binding var shownBusStops: [[String:String]]
    @State var busData:[[String:Any]] = []
    @State var buses: [[String: String]] = []
    
    let timer = Timer.publish(every: 55, on: .main, in: .common).autoconnect()
    
    func busType(type : String) -> String{
        var textToReturn = ""
        if type == "SD"{
            textToReturn = "Single Deck"
        }else if (type == "DD"){
            textToReturn = "Double Deck"
        }else if (type == "BD"){
            textToReturn = "Bendy"
        }else{
            textToReturn = "Bus Type not Found"
        }
        return textToReturn
    }
    
    var body: some View {
        VStack {
            ForEach(shownBusStops, id: \.self
            ){ stopData in
                var stopName = stopData["Name"]!
                var roadName = stopData["RoadName"]!
                DisclosureGroup{
                    VStack{
                        
                    }
                }label:{
                    HStack{
                        VStack{
                            VStack{
                                Text("\(stopName)")
                                     .bold()
                                Text("\(roadName)")
                                    .opacity(0.9)
                            }
                            
                        }
                        Spacer()
                        VStack{
                            
                        }
                    }
                }
                
                
            }
            
        }
        .padding(.top)
        .onChange(of: shownBusStops){ _ in
            getNewData()
            print(shownBusStops)
            var x = [false]
            for i in 0..<shownBusStops.count{
                x.append(false)
                //let temp =
                for j in 0..<(busData["Services"] as? [[String: Any]]).count{
                    
                }
            }
            isDefaultsExpanded = x
            
        }
        .onReceive(timer) { _ in
            getNewData() // Recieve new data from API every 55s
        }
        .onAppear{
            
        }
    }
    
    func getNewData() {
        for stopData in shownBusStops {
            fetchStopData.fetchBuses(BusStopCode: Int(stopData["BusStopCode"]!)!) { result in
                switch result {
                case .success(let stop):
                    DispatchQueue.main.async {
                        busData.append(stop)
                    }
                case .failure(let error):
                    print("Error in Getting Bus Stops: \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
