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
import SwiftDate

struct ContentView: View {
    @ObservedObject var fetchStops = FetchBusStops()
    @ObservedObject var userSettings = UserSettings()
    @ObservedObject var shownStops = ShownStops()
    
    #warning("ONLY ONE OBSERVEDOBJECT DECLARED HERE, EVERYTHING ELSE @BINDING")
    
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
    @State var favouritedBusStopData: [[String:String]] = []
    @State var favouritedBusStopTemp: [[String:Any]] = []
    
    let timer = Timer.publish(every: 55, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ScrollView {
            if (userSettings.favouritedBusStops.count != 0) {
                VStack {
                    ForEach(favouritedBusStopData, id: \.self
                    ){ stopData in
                        BusView(stopData: stopData, favouriteBusStops: userSettings.favouritedBusStops)
                            .padding(.horizontal)
                    }
                }
            } else {
                Text("You have not Favourited anything!")
            }
            
            Spacer()
                .frame(height: 100)
        }.onChange(of: shownBusStops){ _ in
            var x = [false]
            for _ in 0..<shownBusStops.count{
                x.append(false)
            }
            isDefaultsExpanded = x
        }
        .onAppear {
            favouritedBusStopTemp = userSettings.sgBusStopLoc.filter { val in
                let code = Int(val["BusStopCode"]! as! String)!
                return userSettings.favouritedBusStops.contains(code)
            }
            
            for tempData in favouritedBusStopTemp {
                favouritedBusStopData.append(tempData.mapValues { value -> String in
                    if let str = value as? String {
                        return str
                    } else if let int = value as? Int {
                        return String(int)
                    } else if let double = value as? Double {
                        return String(double)
                    } else {
                        return ""
                    }
                })
            }
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
    
    @State var isDefaultsExpanded = [false]
    @Binding var shownBusStops: [[String:String]]
    @State var busData:[[String:Any]] = []
    @State var buses: [[String: String]] = []
    
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
        ScrollView {
            VStack {
                if (shownBusStops.count != 0) {
                    ForEach(shownBusStops, id: \.self
                    ){ stopData in
                        BusView(stopData: stopData, favouriteBusStops: userSettings.favouritedBusStops)
                            .padding(.horizontal)
                    }
                } else {
                    Text("Click 'Reload' in an area with Bus Stops!")
                }
            }
            .onChange(of: shownBusStops){ _ in
                var x = [false]
                for _ in 0..<shownBusStops.count{
                    x.append(false)
                }
                isDefaultsExpanded = x
            }
            
            Spacer()
                .frame(height: 100)
        }
    }
}

struct BusView: View {
    
    var stopData: [String: String]
    @State var favouriteBusStops: [Int] = []
    let timer = Timer.publish(every: 55, on: .main, in: .common).autoconnect()
    
    @ObservedObject var fetchStopData = FetchBuses()
    @ObservedObject var userSettings = UserSettings()
    
    @State private var busData: [String: Any] = [:]
    
    var body: some View {
        
        let stopName = stopData["Name"]!
        let roadName = stopData["RoadName"]!
        let busStopCode = Int(stopData["BusStopCode"]!)!
        
        VStack {
            DisclosureGroup{
                VStack(alignment: .leading) {
                    if let servicesData = busData["Services"], let services = servicesData as? [[String: Any]] {
                        ForEach(0..<services.count) { serviceIndex in
                            let service = services[serviceIndex]
                            let serviceNo = service["ServiceNo"] as! String
                            
                            let nextBuses: [[String: String]] = {
                                var buses: [[String: String]] = []
                                
                                if let nextBus = service["NextBus"] { buses.append(nextBus as! [String: String]) }
                                if let nextBus = service["NextBus2"] { buses.append(nextBus as! [String: String]) }
                                if let nextBus = service["NextBus3"] { buses.append(nextBus as! [String: String]) }
                                
                                return buses
                            }()
                            
                            Divider()
                            
                            HStack {
                                Text(serviceNo)
                                    .frame(width: 100, alignment: .leading)
                                    .font(.system(size: 18, weight: .bold))
                                
                                Spacer()
                                
                                let colors = [Color(red: 180/255, green: 174/255, blue: 210/255), Color(red: 180/255, green: 174/255, blue: 210/255), Color(red: 229/255, green: 223/255, blue: 255/255)]

                                ForEach(0..<nextBuses.count) { nextBusIndex in
                                    let bus = nextBuses[nextBusIndex]
                                    if let date = getDate(from: bus["EstimatedArrival"]!),
                                        let busArrivalTime = Int(round(date.timeIntervalSinceNow / 60)) {
                                        
                                        VStack {
                                            if busArrivalTime < 0 {
                                                Text("Bye!")
                                            } else if busArrivalTime < 1 {
                                                Text("Run.")
                                            } else {
                                                Text("\(busArrivalTime)")
                                            }
                                        }
                                        .frame(width: 50, height: 50)
                                        .background(colors[nextBusIndex])
                                        .cornerRadius(8)
                                        .font(.system(size: 18, weight: .bold))
                                        
                                    } else {
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }label:{
                VStack {
                    HStack {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading) {
                                Text("\(stopName)")
                                    .foregroundColor(Color(.label))
                                    .bold()
                                Text("\(roadName)")
                                    .foregroundColor(Color(.label))
                                    .opacity(0.8)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    if let servicesData = busData["Services"], let services = servicesData as? [[String: Any]] {
                                        ForEach(0..<services.count) { serviceIndex in
                                            let service = services[serviceIndex]
                                            let serviceNo = service["ServiceNo"] as! String
                                            Text(serviceNo)
                                                .foregroundColor(Color("DarkBlue"))
                                        }
                                    }
                                }
                            }
                        }
                        Spacer()
                        VStack{
                            Button {
                                if (favouriteBusStops.contains(busStopCode)) {
                                    favouriteBusStops.remove(at: favouriteBusStops.firstIndex(of: busStopCode)!)
                                } else {
                                    favouriteBusStops.append(busStopCode)
                                }
                                #warning("Need to change to not ObservedObject")
                                userSettings.favouritedBusStops = favouriteBusStops
                            } label: {
                                if (favouriteBusStops.contains(busStopCode)) {
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 35))
                                        .foregroundColor(Color.red)
                                } else {
                                    Image(systemName: "heart")
                                        .font(.system(size: 35))
                                        .foregroundColor(Color.gray)
                                }
                            }
                        }
                    }
                }
                
            }.accentColor(.black)
            Rectangle()
                .frame(height: 0.4)
                .foregroundColor(.black)
        }
        .onAppear {
            fetchStopData.fetchBuses(BusStopCode: busStopCode) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.busData = value
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        .onReceive(timer) { _ in
            fetchStopData.fetchBuses(BusStopCode: busStopCode) { result in
                switch result {
                case .success(let value):
                    DispatchQueue.main.async {
                        self.busData = value
                    }
                case .failure(let error):
                    print("Error in Getting Bus Stops: \(error)")
                }
            }
        }
    }
    
    func getDate(from dateString: String) -> Date? {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        let date = dateFormatter.date(from: dateString)
        
        return date
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
