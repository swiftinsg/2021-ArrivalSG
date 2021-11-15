//
//  TabBar.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import SwiftUI

struct TabBar: View {
    
    private enum Tabs: Hashable {
        case bus
        case train
        case traindisruption
    }
    
    @State private var selectedTab: Tabs = .bus
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tag(0)
                .tabItem {
                    Text("Bus")
                    Image(systemName: "bus.fill")
                }
            TrainMap()
                .tag(1)
                .tabItem {
                    Text("Train")
                    Image(systemName: "tram.fill")
                }
            TrainDisruption()
                .tag(2)
                .tabItem {
                    Text("Train Disruptions")
                    Image(systemName: "xmark.octagon")
                }
        }
    }
}
