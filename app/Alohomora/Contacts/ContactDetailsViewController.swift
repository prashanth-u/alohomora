//
//  ContactDetailsViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class ContactDetailsViewController: UIViewController {

     var contactObj: Contacts?
    @IBOutlet weak var personImage: UIImageView!
    @IBOutlet weak var isTrusted: UISwitch!
    @IBOutlet weak var mobileTxt: UILabel!
    @IBOutlet weak var nameTxt: UILabel!
    var storageRef: StorageReference!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        storageRef = storage.reference()
        
        nameTxt.text = "\(contactObj!.firstName) \(contactObj!.lastName)"
        mobileTxt.text = contactObj?.phoneNumber
        
        if (contactObj?.trustedContact == 1){
            isTrusted.setOn(true, animated: true)
        } else{
             isTrusted.setOn(false, animated: true)
        }

        let imagePath = contactObj?.imgPath
        let islandRef = storageRef.child(imagePath!)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
               // let image = UIImage(data: data!)
                self.personImage.image =  self.resizeImage(image: UIImage(data: data!)!, targetSize: CGSize(width: 84, height: 82))
                
                
                // contactCell.userImageView.image = image
                self.personImage.layer.borderWidth = 1
                self.personImage.layer.masksToBounds = false
                self.personImage.layer.borderColor = UIColor.clear.cgColor
                self.personImage.layer.cornerRadius = self.personImage.frame.height/2
                self.personImage.clipsToBounds = true
            }
            
        }
        // Do any additional setup after loading the view.
    }
    

    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
