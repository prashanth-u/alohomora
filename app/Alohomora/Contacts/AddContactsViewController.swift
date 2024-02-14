//
//  AddContactsViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 1/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class AddContactsViewController: UIViewController,  UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var db: Firestore!
    var isTrusted = -99
    var storageRef: StorageReference!
    
    @IBOutlet weak var firstnameTxt: UITextField!
    @IBOutlet weak var lastnameTxt: UITextField!
    @IBOutlet weak var switchController: UISwitch!
    @IBOutlet weak var phoneNumberTxt: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()




    }
    
    @IBAction func imageUpload(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
   
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
         //   imageView.image = pickedImage
            //imageView.image =  self.resizeImage(image: pickedImage, targetSize: CGSize(width: 84, height: 84))

            imageView.image = pickedImage
            imageView.layer.borderWidth = 1
            imageView.layer.masksToBounds = false
            imageView.layer.borderColor = UIColor.clear.cgColor
            imageView.layer.cornerRadius = imageView.frame.height/2
            imageView.clipsToBounds = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        displayMessage("There was an error in getting the image", "Error")
    }
    
    
    @IBAction func saveContact(_ sender: Any) {
    
        //references - https://firebase.google.com/docs/storage/ios/upload-files
        guard let image = imageView.image else {
            displayMessage("Cannot save until a photo has been taken!", "Error")
            return
        }
        
        let date = UInt(Date().timeIntervalSince1970)
        var data = Data()
        data = image.jpegData(compressionQuality: 0.25)!
        
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                       .userDomainMask, true)[0] as String
       
        
        let userID = Auth.auth().currentUser!.uid
      
       
            
        let name = firstnameTxt.text! +  "_" + lastnameTxt.text!
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
                
                print("URL--------")
                print(downloadURL)
                self.addToDB(name: name)
            }
        }
        
     

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
    
    
    func addToDB(name: String){
         let userID = Auth.auth().currentUser!.uid
        if (firstnameTxt.text!.isEmpty && lastnameTxt.text!.isEmpty && phoneNumberTxt.text!.isEmpty){
            let alertController = UIAlertController(title: "Error", message: "Please enter the required data.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            if ( switchController.isOn) {
                isTrusted = 1
            }else {
                isTrusted = 0
            }
            let name = firstnameTxt.text! +  "_" + lastnameTxt.text!
             let path = "\(userID)/trusted/\(name).jpeg"
            //reference - https://firebase.google.com/docs/firestore/data-model
            self.db
                .collection("UserData").document(userID)
                .collection("Contacts").document(name)
                .setData([
                    "firstName": self.firstnameTxt.text!,
                    "lastName": self.lastnameTxt.text!,
                    "phoneNumber": self.phoneNumberTxt.text!,
                    "trustedContact": isTrusted,
                    "imgUrl": name,
                    "imgPath":path
                    
                ]) { err in
                    if err != nil {
                        let alertController = UIAlertController(title: "Error", message: "Oops! Looks like something went wrong. Please try again or contact customer support at help@alohomora.com", preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                        
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        self.navigationController?.popViewController(animated: true)
                        
                        //self.performSegue(withIdentifier: "linkToHomeSegue", sender: self)
                        print("Document successfully written!")
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
    
    



}

