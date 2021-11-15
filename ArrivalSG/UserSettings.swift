//
//  UserSettings.swift
//  ArrivalSG
//
//  Created by Ethan Chew on 15/11/21.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    let userDefaults = UserDefaults.standard
    
    @Published var isNeedReloadData: Bool {
        didSet {
            userDefaults.set(isNeedReloadData, forKey: "isNeedReloadData")
        }
    }
    
    init() {
        self.isNeedReloadData = userDefaults.bool(forKey: "isNeedReloadData") as? Bool ?? true
    }
}
