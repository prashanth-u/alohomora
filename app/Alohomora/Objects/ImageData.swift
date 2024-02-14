//
//  ImageData.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 6/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class ImageData: Codable {
    var imgUrl: String
    var imgPath: String
    
    
    init(imgUrl: String, imgPath: String) {
        
        self.imgUrl = imgUrl
        self.imgPath = imgPath
    }
}
