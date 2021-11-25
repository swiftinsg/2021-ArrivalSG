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
        
        // Find CheckWithin
        let centralLocation = CLLocation(latitude: centreCoordinate.latitude, longitude: centreCoordinate.longitude)
        func getRadius() -> Double {
            let topCentralLat: Double = centralLocation.coordinate.latitude - uiView.region.span.latitudeDelta/2
            let topCentralLocation = CLLocation(latitude: topCentralLat, longitude: centralLocation.coordinate.longitude)
            let radius = centralLocation.distance(from: topCentralLocation)
            return radius
        }
        
        func checkPtWithin(pt: CLLocation) -> Bool {
            let distCentreToPt = pt.distance(from: centralLocation) / 1000 // In km
//            print(distCentreToPt, getRadius())
//            if (distCentreToPt > getRadius()) {
//                return false
//            } else {
//                return true
//            }
            print(distCentreToPt, 3)
            if (distCentreToPt > 3) {
                return false
            } else {
                return true
            }
        }
        
        var busStopLoc = userSettings.sgBusStopLoc
        
        if (busStopLoc.count != 1) {
            let filteredAnnotations = busStopLoc.filter { val in
                let pt = CLLocation(latitude: val["Latitude"] as! CLLocationDegrees, longitude: val["Longitude"] as! CLLocationDegrees)
                return checkPtWithin(pt: pt)
            }
            for i in 0..<filteredAnnotations.count {
                let newLocation = MKPointAnnotation()
                newLocation.title = filteredAnnotations[i]["Name"] as? String
                newLocation.coordinate = CLLocationCoordinate2D(latitude: busStopLoc[i]["Latitude"] as! CLLocationDegrees, longitude: busStopLoc[i]["Longitude"] as! CLLocationDegrees)
                uiView.addAnnotation(newLocation)
            }
        }
        
        var region = locationModel.region {
            didSet {
                uiView.setRegion(locationModel.region, animated: true)
            }
        }
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centreCoordinate = mapView.centerCoordinate
        }
    }
}

extension MKPointAnnotation {
    
}
