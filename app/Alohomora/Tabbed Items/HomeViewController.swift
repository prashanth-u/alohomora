//
//  HomeViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 6/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import CodableFirebase
import UserNotifications
import CodableFirebase


class HomeViewController: UIViewController, UNUserNotificationCenterDelegate {

    var db: Firestore!
    var userID = ""
    var storageRef: StorageReference!
    var contactList: [Contacts] = []
    var trustedList: [Contacts] = []
    var deviceList: [Device] = []

    @IBOutlet weak var doorView: UIView!

    @IBOutlet weak var deviceTotalTxt: UILabel!
    @IBOutlet weak var deviceView: UIView!
    @IBOutlet weak var totalTrustedTxt: UILabel!
    @IBOutlet weak var trustedView: UIView!
    @IBOutlet weak var totalContactsTxt: UILabel!
    @IBOutlet weak var contactsView: UIView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        userID = Auth.auth().currentUser!.uid
        addShadow(view: deviceView)
        addShadow(view: trustedView)
        addShadow(view: contactsView)
        addShadow(view: doorView)

       

       

       
        listenForChanges()
        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        getDeviceTotal()
    }

    @IBAction func openDoor(_ sender: Any) {
        self.db
            .collection("UserData").document(userID)
            .collection("door").document()
            .setData([
                "time": FieldValue.serverTimestamp(),
                "allow": 1
                
                
            ]) { err in
                if err != nil {
                    let alertController = UIAlertController(title: "Error", message: "Oops! Looks like something went wrong. Please try again or contact customer support at help@alohomora.com", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
                   // self.navigationController?.popViewController(animated: true)
                    
                    let alertController = UIAlertController(title: "Success", message: "The door was opened!", preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                    //self.performSegue(withIdentifier: "linkToHomeSegue", sender: self)
                    print("Document successfully written!")
                }
        }
        
    }
    func listenForChanges() {
        
        let userID = Auth.auth().currentUser!.uid

        db.collection("DeviceData")
            .document(userID)
            .collection("motionData")
            .whereField("userId", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {
                        
                        do {
                            print("detected---")
                            
                            let sData = try FirestoreDecoder().decode(Motion.self, from: diff.document.data())
                            self.updateNotificationsMotions(motionData: sData)
                            
                        } catch let error {
                            print(error)
                        }
                        
                        
                    }
                    
                }
        }
        


        db.collection("DeviceData")
            .document(userID)
            .collection("pushData")
            .whereField("userId", isEqualTo: userID)
            .addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .added) {

                     
                        do {
                            
                        let sData = try FirestoreDecoder().decode(ButtonData.self, from: diff.document.data())
                            self.updateNotifications(buttonData: sData)

                        } catch let error {
                            print(error)
                        }
                  
                        
                    }
                    
                }
        }
    }
  
    func updateNotificationsMotions(motionData: Motion){
        let center =  UNUserNotificationCenter.current()
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Movement Alert"
        content.subtitle = "Motion Detected!"
        
        
      
        
        content.body = "Hey there! Looks like someone is outside your house!"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
    
    
    
    func updateNotifications(buttonData: ButtonData){
        let center =  UNUserNotificationCenter.current()
        
        //create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Movement Alert"
       
        
        if(buttonData.name == "Unknown" || buttonData.name == "No Face"){
             content.body = "Hey there! Looks like someone just rang the bell!"
        } else {
             content.body = "Hey there! Looks like \(buttonData.name) just rang the bell!"
        }
       
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval:2.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: "ContentIdentifier", content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if error != nil {
                print("error \(String(describing: error))")
            }
        }
    }
  

    

    


    
    
    func getData(){
        contactList.removeAll()
        trustedList.removeAll()
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
       
        print(userID)
        let basicQuery = Firestore.firestore().collection("UserData").document(userID).collection("Contacts")
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for contacts in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(Contacts.self, from: contacts.data())
                    self.contactList.append(sData)
                    if( sData.trustedContact == 1){
                        self.trustedList.append(sData)
                    }
                  
                } catch let error {
                    print(error)
                }
                
            }
            
            self.totalContactsTxt.text = "\(self.contactList.count)"
            self.totalTrustedTxt.text = "\(self.trustedList.count)"

            
        }
        
    }

    
    func getDeviceTotal(){
        deviceList.removeAll()
        let basicQuery = Firestore.firestore().collection("UserData").document(userID).collection("Devices")
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for devices in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(Device.self, from: devices.data())
                    self.deviceList.append(sData)
                   
                    
                } catch let error {
                    print(error)
                }
                
            }
            
            self.deviceTotalTxt.text = "\(self.deviceList.count)"
           
            
            
        }
    }
    
    func addShadow(view: UIView){
        
        view.layer.cornerRadius = 20.0
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        view.layer.shadowRadius = 12.0
        view.layer.shadowOpacity = 0.7

    }
}

