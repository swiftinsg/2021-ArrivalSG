//
//  CarparkAvailabilityView.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 17/3/22.
//

import SwiftUI
import Snap
import CoreData
import MapKit
import SwiftDate

struct CarparkAvailabilityView: View {
    @ObservedObject var fetchStops = FetchBusStops()
    @ObservedObject var userSettings = UserSettings()
    
    // Variables
    @State var locationModel = LocationViewModel()
    @State public var currentlySelected = "Location"
    @State var centreCoordinate = CLLocationCoordinate2D()
    @State var isShowCarparks = false
    @State var isShowNewStops = false // VALUE IS A CONSTANT FALSE. DO NOT UPDATE VALUE2
    @State var shownBusStops: [[String:String]] = [] // VALUE IS A CONSTANT FALSE. DO NOT UPDATE VALUE
    @State var shownCarparks: [CarparkAvailabilityMData] = []
    
    @State var refresh: Bool = false
    
    @State var reloadTimer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    
    init() {
        locationModel.checkIfLocationEnabled()
    }

    var body: some View {
        // Map
        GeometryReader { geometry in
            ZStack {
                MapView(centreCoordinate: $centreCoordinate, showNewStops: $isShowNewStops, showCarparks: $isShowCarparks, shownBusStops: $shownBusStops, shownCarparks: $shownCarparks)
                    .edgesIgnoringSafeArea(.all)
                    .accentColor(Color(.systemPink))
                    .onChange(of: shownBusStops) { _ in
                        
                    }
                
                SnapDrawer(large: .paddingToTop(150), medium: .fraction(0.4), tiny: .height(100), allowInvisible: false) { state in
                    Text("Click 'Reload' in an area with Carparks!")
                }
                
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        CarparkOverlayControls(isShowCarparks: $isShowCarparks)
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

struct CarparkOverlayControls: View {    
    @Binding var isShowCarparks: Bool
    
    var body: some View {
        // Buttons in the top right hand corner
        VStack {
            Button {
                isShowCarparks = true
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

struct ListCarparks: View {
    let timer = Timer.publish(every: 120, on: .main, in: .common).autoconnect() // Carpark Availability will update every 2 minutes
    
    var body: some View {
        // Carpark DisclosureGroup goes here
        VStack {
            
        }
        .onReceive(timer) { _ in
            // Reload Data goes here
        }
    }
}

struct CarparkAvailabilityView_Previews: PreviewProvider {
    static var previews: some View {
        CarparkAvailabilityView()
    }
}
