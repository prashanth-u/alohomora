//
//  Device.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class Device: Codable {
    var deviceId: String
    var location: String
    
    
    init(location: String, deviceId: String) {
        
        self.location = location
        self.deviceId = deviceId
    }
}
