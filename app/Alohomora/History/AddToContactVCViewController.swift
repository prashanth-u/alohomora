//
//  AddToContactVCViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import Firebase

class AddToContactVCViewController: UIViewController {
    
    var buttonData: ButtonData?
    @IBOutlet weak var isTrusted: UISwitch!
    @IBOutlet weak var phoneNumTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    var isTrustedNum = -99
    var storageRef: StorageReference!
    var db: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        loadImage()
        
    }
    
    @IBAction func saveUser(_ sender: Any) {
        addToDB()
    }
    
    func loadImage(){
        
        let imagePath = buttonData?.image_url
        let islandRef = storageRef.child(imagePath!)
        islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                // let image = UIImage(data: data!)
                self.userImage.image =  self.resizeImage(image: UIImage(data: data!)!, targetSize: CGSize(width: 84, height: 82))
                
                
                // contactCell.userImageView.image = image
                self.userImage.layer.borderWidth = 1
                self.userImage.layer.masksToBounds = false
                self.userImage.layer.borderColor = UIColor.clear.cgColor
                self.userImage.layer.cornerRadius = self.userImage.frame.height/2
                self.userImage.clipsToBounds = true
            }
            
        }
    }
    func addToDB(){
        let userID = Auth.auth().currentUser!.uid
        if (firstNameTxt.text!.isEmpty && lastNameTxt.text!.isEmpty){
            let alertController = UIAlertController(title: "Error", message: "Please enter the required data.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            if ( isTrusted.isOn) {
                isTrustedNum = 1
            }else {
                isTrustedNum = 0
            }
            var data = Data()
            data = userImage.image!.jpegData(compressionQuality: 0.7)!
            
            let name = firstNameTxt.text! +  "_" + lastNameTxt.text!
            let path = "\(userID)/trusted/\(name).jpeg"
            
            let riversRef = storageRef.child("\(userID)/trusted/\(name).jpeg")
            
            let uploadTask = riversRef.putData(data, metadata: nil) { (metadata, error) in
                guard let metadata = metadata else {
                    // Uh-oh, an error occurred!
                    return
                }
                // Metadata contains file metadata such as size, content-type.
                let size = metadata.size
                riversRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        return
                    }
                    
                    //reference - https://firebase.google.com/docs/firestore/data-model
                    self.db
                        .collection("UserData").document(userID)
                        .collection("Contacts").document(name)
                        .setData([
                            "firstName": self.firstNameTxt.text!,
                            "lastName": self.lastNameTxt.text!,
                            "phoneNumber": self.phoneNumTxt.text!,
                            "trustedContact": self.isTrustedNum,
                            "imgUrl": name,
                            "imgPath":path
                            
                        ]) { err in
                            if err != nil {
                                let alertController = UIAlertController(title: "Error", message: "Oops! Looks like something went wrong. Please try again or contact customer support at help@alohomora.com", preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                            } else {
                                var full_name = self.firstNameTxt.text
                               
                                self.updateData( name: full_name!)
                                self.navigationController?.popViewController(animated: true)
                                
                                //self.performSegue(withIdentifier: "linkToHomeSegue", sender: self)
                                print("Document successfully written!")
                            }
                    }
                    
                }
            }
            
            
        }
        
    }
    
    
    func updateData( name: String){
        
       
       
        db.collection("pushButton").whereField("image_url", isEqualTo: buttonData?.image_url)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    print("got the docs")
                    for document in querySnapshot!.documents {
                      
                        print(document.documentID)
                        let washingtonRef = self.db.collection("pushButton").document(document.documentID)
                        washingtonRef.updateData([
                            "name": name
                        ]) { err in
                            if let err = err {
                                print("did not update")
                                print("Error updating document: \(err)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                        
                        print("\(document.documentID) => \(document.data())")
                    }
                }
        }
        
        
    }
    
    func displayMessage(_ message: String,_ title: String) {
        let alertController = UIAlertController(title: title, message: message,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default,
                                                handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
