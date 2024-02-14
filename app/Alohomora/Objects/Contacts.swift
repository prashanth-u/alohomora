//
//  Contacts.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 5/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import Foundation
import Firebase
import CodableFirebase

class Contacts: Codable {
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var imgUrl: String
    var trustedContact: Int
    var imgPath: String
    
    init(firstName: String, lastName: String, phoneNumber: String, imgUrl: String, trustedContact: Int, imgPath: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.imgUrl = imgUrl
        self.imgPath = imgPath
        self.trustedContact = trustedContact
    }
}
