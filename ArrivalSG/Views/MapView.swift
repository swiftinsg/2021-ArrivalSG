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
    @Binding var showNewStops: Bool
    @State var locationModel = LocationViewModel()
    @ObservedObject var userSettings = UserSettings()
    @Binding var shownBusStops : [[String:String]]
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.showsUserLocation = true
        
        if showNewStops {
            print("Showing new stops")
            let busStopLoc = userSettings.sgBusStopLoc
            
            let centralLocation = CLLocation(latitude: uiView.centerCoordinate.latitude, longitude: uiView.centerCoordinate.longitude)
            func checkPtWithin(pt: CLLocation) -> Double {
                let distCentreToPt = pt.distance(from: centralLocation) / 1000 // In km
                return distCentreToPt
            }
            
            uiView.removeAnnotations(uiView.annotations)
            if (busStopLoc.count != 1) {
                var temp: [[String:String]] = []
                var filteredAnnotations = busStopLoc.filter { val in
                    let pt = CLLocation(latitude: CLLocationDegrees({ () -> String in
                        if let lat = val["Latitude"]! as? String {
                            return lat
                        } else {
                            return String(val["Latitude"]! as! Double)
                        }
                    }())! , longitude: CLLocationDegrees({ () -> String in
                        if let lon = val["Longitude"]! as? String {
                            return lon
                        } else {
                            return String(val["Longitude"]! as! Double)
                        }
                    }())!)
                    return checkPtWithin(pt: pt) <= 1
                }
                
                
                for i in 0..<filteredAnnotations.count {
                    let newLocation = MKPointAnnotation()
                    newLocation.title = filteredAnnotations[i]["Name"] as? String
                    newLocation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees( filteredAnnotations[i]["Latitude"] as! String)!, longitude: CLLocationDegrees( filteredAnnotations[i]["Longitude"] as! String)!)
                    uiView.addAnnotation(newLocation)
                    temp.append(filteredAnnotations[i].mapValues { value -> String in
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
                
                shownBusStops = temp.sorted(by: {a, b in
                    CLLocation(latitude: CLLocationDegrees({ () -> String in
                        if let lat = a["Latitude"]! as? String {
                            return lat
                        } else {
                            return String(a["Latitude"]! as! Double)
                        }
                    }())! , longitude: CLLocationDegrees({ () -> String in
                        if let lon = a["Longitude"]! as? String {
                            return lon
                        } else {
                            return String(a["Longitude"]! as! Double)
                        }
                    }())!).distance(from: centralLocation) < CLLocation(latitude: CLLocationDegrees({ () -> String in
                        if let lat = b["Latitude"]! as? String {
                            return lat
                        } else {
                            return String(b["Latitude"]! as! Double)
                        }
                    }())! , longitude: CLLocationDegrees({ () -> String in
                        if let lon = b["Longitude"]! as? String {
                            return lon
                        } else {
                            return String(b["Longitude"]! as! Double)
                        }
                    }())!).distance(from: centralLocation)
                })
            }
        }
        showNewStops = false
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(locationModel.region, animated: true)
        locationModel.mapView = mapView
        locationModel.checkIfLocationEnabled()
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
}
class ShownStops: ObservableObject {
    @Published var shownBusStops: [Int] = []
}
