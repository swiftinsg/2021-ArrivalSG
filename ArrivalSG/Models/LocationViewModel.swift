//
//  LocationViewModel.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

// Location Manager
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    var mapView: MKMapView?
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) {
        didSet {
            mapView?.setRegion(region, animated: true)
        }
    }
    @Published var centerCoordinate:CLLocationCoordinate2D?
    @Published var locationAuthError = ["", ""]
    @Published var isAlertPresented = false
    @Published var userLocation:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
    @State var hasSetRegion = false
    
    func checkIfLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
            locationManager?.requestWhenInUseAuthorization()
            locationManager?.startUpdatingLocation()
         } else {
             locationAuthError = ["Location Access Denied", "You have denied this app to use your location. Go into settings to resolve it."]
             isAlertPresented = true
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
            locationAuthError = ["Restricted Location", "Your Location is Restricted, possibly due to Parental Controls."]
            isAlertPresented = true
        case .denied:
            locationAuthError = ["Location Access Denied", "You have denied this app to use your location. Go into settings to resolve it."]
            isAlertPresented = true
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), latitudinalMeters: 1000, longitudinalMeters: 1000)
            userLocation = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198)
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
}
