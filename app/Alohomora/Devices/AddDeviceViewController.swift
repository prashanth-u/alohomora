//
//  AddDeviceViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AddDeviceViewController: UIViewController {

     var db: Firestore!
    
     var isLinked = -99
    @IBOutlet weak var locationTxt: UITextField!
    @IBOutlet weak var deviceIdTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
    }
    

    @IBAction func addDevice(_ sender: Any) {
        if (deviceIdTxt.text!.isEmpty && locationTxt.text!.isEmpty ){
            let alertController = UIAlertController(title: "Error", message: "Please enter the required data.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            checkDevice()
        }
    }
    
    func checkDevice(){
        db.collection("Devices").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    // print("\(document.documentID) => \(document.data())")
                    print(document.documentID)
                    //the id entered by the user exists in teh "Devices" collection
                    
                    if( self.deviceIdTxt.text == document.documentID){
                        self.isLinked = 100
                        print("same same " + document.documentID)
                        let userID = Auth.auth().currentUser!.uid
                        
                        // adding to the user table
                        //reference - https://firebase.google.com/docs/firestore/data-model
                        self.db
                            .collection("UserData").document(userID)
                            .collection("Devices").document(document.documentID)
                            .setData([
                                "location": self.locationTxt.text ?? "Main door",
                                  "deviceId": self.deviceIdTxt.text
                                
                            ]) { err in
                                if err != nil {
                                    let alertController = UIAlertController(title: "Error", message: "Oops! Looks like something went wrong. Please try again or contact customer support at help@alohomora.com", preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                    
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: nil)
                                } else {
                                    self.updateDevicesTable(userId: userID)
                                       self.navigationController?.popViewController(animated: true)
                                   // self.performSegue(withIdentifier: "linkToHomeSegue", sender: self)
                                    print("Document successfully written!")
                                }
                        }
                        
                        
                    }
                }
                
                if( self.isLinked == -99){
                    
                    let alertController = UIAlertController(title: "Error", message: "Oops! Looks like that ID does not exsist. Please contact customer support at help@alohomora.com", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func updateDevicesTable( userId: String){
        
        let deviceID = deviceIdTxt.text
        let washingtonRef = db.collection("Devices").document(deviceID!)
        
        washingtonRef.updateData([
            "hasUser": 1,
            "userId": userId,
            "lastUpdated": FieldValue.serverTimestamp()
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
        
        
        
        
    }

}
