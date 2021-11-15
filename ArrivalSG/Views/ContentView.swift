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
    // Variables
    @State var viewModel = ContentViewModel()
    @State public var currentlySelected = "Location"
        
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
                    .ignoresSafeArea()
                    .onAppear{
                        viewModel.checkIfLocationEnabled()
                    }
                SnapDrawer(large: .paddingToTop(400), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in

                }
                
                VStack(alignment: .trailing) {
                    HStack(alignment: .top) {
                        Spacer()
                            .offset(y: geometry.safeAreaInsets.top)
                        OverlayControls()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct OverlayControls: View {
    var body: some View {
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
        }
        .padding()
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
