//
//  ButtonData.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 7/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class ButtonData: Codable {
    var image_url: String
    let time: Timestamp
    var userId: String
    var name: String
    
    
    init(image_url: String, time: Timestamp, userId: String, name: String) {
        
        self.image_url = image_url
        self.time = time
        self.userId = userId
        self.name = name
    }
}
//extension Timestamp: TimestampType {}
