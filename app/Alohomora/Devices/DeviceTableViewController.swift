//
//  DeviceTableViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase
import CodableFirebase

class DeviceTableViewController: UITableViewController {

    let CELL = "deviceCell"
    var storageRef: StorageReference!
    var deviceList: [Device] = []
    var db: Firestore!
    
    let cellSpacingHeight: CGFloat = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        // [END setup]
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.deviceList.removeAll()
        //tableView.reloadData()
        loadUserData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deviceList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
            let deviceCell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! DeviceTableViewCell
            let device = deviceList[indexPath.row]
            
            //references - https://stackoverflow.com/questions/28598830/spacing-between-uitableviewcells/45515483
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 149))
            
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.clipsToBounds = true
            
            whiteRoundedView.layer.cornerRadius = 20
            whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
            whiteRoundedView.layer.shadowOpacity = 0.2
            
            deviceCell.contentView.addSubview(whiteRoundedView)
            deviceCell.contentView.sendSubviewToBack(whiteRoundedView)
            
            
            deviceCell.layer.cornerRadius = 10
            
            deviceCell.locationTxt.text = device.location
            deviceCell.deviceIdTxt.text = device.deviceId
            


            return deviceCell
    }
    
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//
//        return false
//    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle:
//        UITableViewCell.EditingStyle,
//                            forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete  {
//            self.deviceList.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    func loadUserData(){
        print("DATAaaaa")
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
        let userID = Auth.auth().currentUser!.uid
        print(userID)
        let basicQuery = Firestore.firestore().collection("UserData").document(userID).collection("Devices")
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for dev in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(Device.self, from: dev.data())
                    self.deviceList.append(sData)
                   
                   
                } catch let error {
                    print(error)
                }
                
            }
            
          
            self.tableView.reloadData()
            
        }
    }
    
   

}
