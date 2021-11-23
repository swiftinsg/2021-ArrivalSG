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
//    var annotations: [MKPointAnnotation]
    
    @State var locationModel = LocationViewModel()
//    @State private var busStops = [MKPointAnnotation]()
    @ObservedObject var userSettings = UserSettings()
    
//    //Bus Stop Annotation
//    for busStop in BusStopLoc {
//        let busStop = MKPointAnnotation()
//        busStop.coordinate.longitude = BusStopLoc.longitude
//        busStop.coordinate.latitude = BusStopLoc.latitude
//        self.locations?.append(busStop)
//    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.setRegion(locationModel.region, animated: true)
        uiView.showsUserLocation = true
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
