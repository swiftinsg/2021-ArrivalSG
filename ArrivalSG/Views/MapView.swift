//
//  MapView.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 19/11/21.
//

import Foundation
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    @Binding var centreCoordinate: CLLocationCoordinate2D
    @State var locationModel = LocationViewModel()
    @ObservedObject var userSettings = UserSettings()
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(locationModel.region, animated: true)
        uiView.showsUserLocation = true
        
        var region = locationModel.region {
            didSet {
                uiView.setRegion(locationModel.region, animated: true)
            }
        }
        
        uiView.setRegion(locationModel.region, animated: true)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(locationModel.region, animated: true)
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

class Coordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        parent.centreCoordinate = mapView.centerCoordinate
        @ObservedObject var userSettings = UserSettings()
        @State var locationModel = LocationViewModel()
        @ObservedObject var shownStops = ShownStops()
        
        let busStopLoc = userSettings.sgBusStopLoc
        var shownBusStops:[Int] = []
        
        let centralLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        func checkPtWithin(pt: CLLocation) -> Double {
            let distCentreToPt = pt.distance(from: centralLocation) / 1000 // In km
            return distCentreToPt
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        if (busStopLoc.count != 1) {
            let filteredAnnotations = busStopLoc.filter { val in
                let pt = CLLocation(latitude: val["Latitude"] as! CLLocationDegrees, longitude: val["Longitude"] as! CLLocationDegrees)
                return checkPtWithin(pt: pt) <= 1
            }
            
            for i in 0..<filteredAnnotations.count {
                let newLocation = MKPointAnnotation()
                newLocation.title = filteredAnnotations[i]["Name"] as? String
                newLocation.coordinate = CLLocationCoordinate2D(latitude: filteredAnnotations[i]["Latitude"] as! CLLocationDegrees, longitude: filteredAnnotations[i]["Longitude"] as! CLLocationDegrees)
                mapView.addAnnotation(newLocation)
                shownBusStops.append(Int("\(filteredAnnotations[i]["BusStopCode"]!)")!)
            }
        }
        shownStops.shownBusStops = shownBusStops
    }
}

class ShownStops: ObservableObject {
    @Published var shownBusStops: [Int] = []
}
