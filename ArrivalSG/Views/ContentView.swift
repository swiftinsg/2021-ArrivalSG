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
    
    // Variables
    @State var locationModel = LocationViewModel()
    @State public var currentlySelected = "Location"
    @State var isSettingsOpen = false

    var body: some View {
        
        // Map
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $locationModel.region, showsUserLocation: true)
                    .ignoresSafeArea()
                    .accentColor(Color(.systemPink))
                    .onAppear{
                        locationModel.checkIfLocationEnabled()
                    }
                
                SnapDrawer(large: .paddingToTop(150), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                    ScrollView {
                        VStack(alignment: .leading) {
                            Button(action: {
                                print("Bus Option 1 Pressed")
                            }) {
                                Text("Option 1")
                                    .frame(width: 400, height: 100)
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                print("Bus Option 2 Pressed")
                            }) {
                                Text("Option 2")
                                    .frame(width: 400, height: 100)
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                print("Bus Option 3 Pressed")
                            }) {
                                Text("Option 3")
                                    .frame(width: 400, height: 100)
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                print("Bus Option 4 Pressed")
                            }) {
                                Text("Option 4")
                                    .frame(width: 400, height: 100)
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                            Button(action: {
                                print("Bus Option 5 Pressed")
                            }) {
                                Text("Option 5")
                                    .frame(width: 400, height: 100)
                                    .foregroundColor(Color.black)
                                    .background(Color.red)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                if (isSettingsOpen) {
                    SettingsPopup()
                }
                
                VStack(alignment: .trailing) {
                    HStack(alignment: .top) {
                        Spacer()
                            .offset(y: geometry.safeAreaInsets.top)
                        OverlayControls(isSettingsOpen: $isSettingsOpen)
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
    @Binding var isSettingsOpen: Bool
    
    var body: some View {
        // Buttons in the top right hand corner
        VStack {
            VStack(spacing: 10) {
                Button {
                    print("Current Location button was tapped")
                } label: {
                    Image(systemName: "location")
                }
                Divider()
                Button {
                    print("Favourites button was tapped")
                } label: {
                    Image(systemName: "heart")
                }            }
            .frame(width: 40)
            .padding(.vertical, 9)
            .background(Color(uiColor:  .white))
            .cornerRadius(8)
            
            Button {
                isSettingsOpen.toggle()
            } label: {
                Image(systemName: "gear")
            }
                .frame(width: 40)
                .padding(.vertical, 9)
                .background(Color(uiColor:  .white))
                .cornerRadius(8)
        }
        .padding()
    }
}

struct SettingsPopup: View {
    var body: some View {
        // Temp UI
        VStack(alignment: .center, spacing: 3) {
            Text("Settings")
                .bold()
                .font(.title)
                .foregroundColor(.black)
                .padding()
            Button {
                prepareDataReload()
                
            } label: {
                Text("Reload Bus Data")
            }
                .padding()
                .foregroundColor(.white)
                .background(.cyan)
                .cornerRadius(5)
            
        }
        .padding()
        .background(.white)
        .cornerRadius(5)
    }
    
    func prepareDataReload() {
        var busStopArr:[Int] = []
        @ObservedObject var userSettings = UserSettings()
        @ObservedObject var fetchStops = FetchBusStops()
        @ObservedObject var fetchStopData = FetchBuses()
        
        fetchStops.fetchBusStops() { result in
            switch result {
            case .success(let stops):
                let val = stops.value
                for i in 0..<val.count {
                    busStopArr.append(Int(val[i].BusStopCode) ?? 0)
                }
                userSettings.sgBusStops = busStopArr
                reloadData()
            case .failure(let error):
                print("Error in Getting Bus Stops: \(error)")
            }
        }
        
        
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
        }
    }
}

// Location Manager
class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    @State private var isAlertPresented = false
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) // Placeholder Location
    
    func checkIfLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        } else {
            print("You have denied this app to use your location. Go into settings to resolve it.")
        }
    }
    
    func checkLocationAuth() {
        guard let locationManager = locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            Alert(title: Text("Restricted Location"),
                  message: Text("Your Location is Restricted, possibly due to Parental Controls."),
                  dismissButton: .default(Text("OK")) {
            })
        case .denied:
            Alert(title: Text("Location Access Denied"),
                  message: Text("You have denied this app to use your location. Go into settings to resolve it."),
                  dismissButton: .default(Text("OK")) {
            })
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
