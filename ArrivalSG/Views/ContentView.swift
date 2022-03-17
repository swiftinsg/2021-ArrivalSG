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
    
    @State var refresh: Bool = false
    
    @State var reloadTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    init() {
        locationModel.checkIfLocationEnabled()
    }

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
                        FavouritedScreen(shownBusStops: $shownBusStops, userLocation: $locationModel.userLocation,  favouritedBusStops: $userSettings.favouritedBusStops)
                    }
                    
                    if (currLocationOpen) {
                        CurrLocationScreen(shownBusStops: $shownBusStops, userLocation: $locationModel.userLocation, favouritedBusStops: $userSettings.favouritedBusStops)
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
            .onReceive(reloadTimer) { _ in
                refresh.toggle()
                self.reloadTimer.upstream.connect().cancel()
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
                    if (currLocationOpen) {
                        Image(systemName: "location.fill")
                    } else {
                        Image(systemName: "location")
                    }
                }
                Divider()
                Button {
                    if (favouritedOpen == false) {
                        favouritedOpen = true
                        currLocationOpen = false
                    }
                } label: {
                    if (favouritedOpen) {
                        Image(systemName: "heart.fill")
                    } else {
                        Image(systemName: "heart")
                    }
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
            Text("Information")
                .bold()
                .font(.title2)
                .foregroundColor(.black)
                .padding()
            VStack {
                List {
                    Section(header: Text("Bus Occupancy")) {
                        Text("For Bus Arrivals, the Bus Arrival Background has a deeper purple the more packed the Bus is.")
                            .bold()
                        Text("Light Purple: Seats Available")
                        Text("Darker Purple: Standing Available")
                        Text("Darkest Purple: Limited Standing")
                    }
                    
                    Section(header: Text("Bus Arrival")) {
                        Text("Normally, Bus Arrival should show Bus Arrival Timing in Minutes, but there are Special Cases.")
                        Text("'Run.' -- Bus is arriving in 1 minute or lesser.")
                        Text("'Bye!' -- Bus has left the Bus Stop.")
                    }
                    
                    Section(header: Text("Sorting of Bus Stops")) {
                        Text("Bus Stops are sorted by the distance from the Middle of the Screen. (NOT the UserLocation)")
                    }
                }
                .foregroundColor(.black)
            }
        }
        .frame(height: 500)
        .background(.white)
        .cornerRadius(10)
        .padding(.leading, 5)
        .padding(.trailing, 5)
        .padding()
    }
    
    func prepareDataReload() async throws {
        infoText = "Loading Data..."
        buttonDisabled = true
        var busStopArr:[Int] = []
        var busStopLoc:[[String:Any]] = []
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var fetchStops = FetchBusStops()
        @ObservedObject var fetchStopData = FetchBuses()
        @ObservedObject var carparkAvail = CarparkAvailability()
        
        // Fetch Bus Stops
        try await fetchStops.fetchBusStops()
        let stops = fetchStops.stops
        
        for i in 0..<stops!.count {
            busStopArr.append(Int(stops![i].BusStopCode) ?? 0)
            busStopLoc.append(["Name": stops![i].Description,"RoadName": stops![i].RoadName, "BusStopCode": String(stops![i].BusStopCode), "Latitude": String(stops![i].Latitude), "Longitude": String(stops![i].Longitude)])
        }
        
        userSettings.sgBusStopLoc = busStopLoc
        userSettings.sgBusStops = busStopArr
        
        // Fetch Carpark Availability
        try await carparkAvail.fetchCarparkAvailability()
        userSettings.carparkAvailability = carparkAvail.carparkAvailability ?? [CarparkAvailabilityMData(CarParkID: "", Area: "", Development: "", Location: "", AvailableLots: 0, LotType: "", Agency: "")]
        
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
    @Binding var userLocation: CLLocationCoordinate2D
    @Binding var favouritedBusStops: [Int]
    
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
                        BusView(stopData: stopData, favouriteBusStops: $favouritedBusStops, userLocation: userLocation)
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
    
    @Binding var shownBusStops: [[String:String]]
    @Binding var userLocation: CLLocationCoordinate2D
    @Binding var favouritedBusStops: [Int]
    
    @State var isDefaultsExpanded = [false]
    @State var busData:[[String:Any]] = []
    @State var buses: [[String: String]] = []
    
    var body: some View {
        ScrollView {
            VStack {
                if (shownBusStops.count != 0) {
                    ForEach(shownBusStops, id: \.self
                    ){ stopData in
                        BusView(stopData: stopData, favouriteBusStops: $favouritedBusStops, userLocation: userLocation)
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
    @Binding var favouriteBusStops: [Int]
    @State var userLocation: CLLocationCoordinate2D
    @State var refresh = false
    
    let timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()
    
    @ObservedObject var fetchStopData = FetchBuses()
    @ObservedObject var userSettings = UserSettings()
    
    @State private var busData: [String: Any] = [:]
    
    var body: some View {
        let stopName = stopData["Name"]!
        let roadName = stopData["RoadName"]!
        let busStopCode = Int(stopData["BusStopCode"]!)!
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let stopCoord = CLLocation(latitude: Double(stopData["Latitude"]!)!, longitude: Double(stopData["Longitude"]!)!)
        
        VStack {
            DisclosureGroup {
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
                                   
                                if (nextBuses.count != 0) {
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
                                            .background(Color(bus["Load"]!))
                                            .cornerRadius(8)
                                            .font(.system(size: 18, weight: .bold))
                                            
                                        } else {
                                            Rectangle()
                                                .foregroundColor(.clear)
                                                .frame(width: 50, height: 50)
                                        }
                                    }
                                } else {
                                    Text("End of Service.")
                                        .opacity(0.8)
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
                                    .font(.system(size: 19))
                                    .foregroundColor(Color(.label))
                                    .bold()
                                Text("\(roadName)")
                                    .foregroundColor(Color(.label))
                                    .opacity(0.8)
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    if let servicesData = busData["Services"],
                                       let services = servicesData as? [[String: Any]] {
                                        
                                        ForEach(0..<services.count) { serviceIndex in
                                            if services.count > serviceIndex {
                                                let service = services[serviceIndex]
                                                let serviceNo = service["ServiceNo"] as! String
                                                Text(serviceNo)
                                                    .foregroundColor(Color("DarkBlue"))
                                            }
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
                                refresh.toggle()
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
                            .onChange(of: favouriteBusStops) { _ in
                                userSettings.favouritedBusStops = favouriteBusStops
                                refresh.toggle()
                            }
                            
                            Spacer()
                            
                            Text("\(String(format: "%.2f",(stopCoord.distance(from: location) / 1000))) km")
                                .foregroundColor(Color("DarkBlue"))
                        }
                        .padding(.trailing)
                    }
                }
                
            }.accentColor(.black)
            Rectangle()
                .frame(height: 0.4)
                .foregroundColor(.black)
        }
        .onAppear {
            print("Reloading Buses")
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
