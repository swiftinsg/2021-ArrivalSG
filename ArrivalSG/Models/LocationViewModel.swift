//
//  LocationViewModel.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 16/11/21.
//

import Foundation
import MapKit
import SwiftUI

// Location Manager
class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) // Placeholder Location
    @Published var centerCoordinate:CLLocationCoordinate2D?
    @Published var locationAuthError = ["", ""]
    @Published var isAlertPresented = false
    
    func checkIfLocationEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
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
            print("RegionChange")
            region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuth()
    }
}
