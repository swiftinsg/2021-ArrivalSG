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
        
        let busStopLoc = userSettings.sgBusStopLoc
        print(busStopLoc)
        
        for i in 0..<busStopLoc.count {
            let newLocation = MKPointAnnotation()
            newLocation.title = busStopLoc[i]["Name"]! as! String
            newLocation.coordinate = CLLocationCoordinate2D(latitude: busStopLoc[i]["Latitude"] as! CLLocationDegrees, longitude: busStopLoc[i]["Longitude"] as! CLLocationDegrees)
            uiView.addAnnotation(newLocation)
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
