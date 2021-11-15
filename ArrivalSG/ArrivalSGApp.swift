//
//  ArrivalSGApp.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import SwiftUI

@main
struct ArrivalSGApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabBar()
//            ContentView()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
