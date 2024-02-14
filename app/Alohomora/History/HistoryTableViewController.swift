//
//  HistoryTableViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 7/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase
import CodableFirebase


var tempButtonData: [ButtonData] = []
class HistoryTableViewController: UITableViewController {
    
    
    @IBOutlet weak var timeSegmentContoller: UISegmentedControl!
    

    let CELL = "historyCell"
    var storageRef: StorageReference!
    var buttonDataList: [ButtonData] = []
    var db: Firestore!
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        
        let storage = Storage.storage()
        storageRef = storage.reference()
        userID = Auth.auth().currentUser!.uid
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.buttonDataList.removeAll()
        //tableView.reloadData()
        timeSegmentContoller.selectedSegmentIndex = 0
        loadUserDataToday()
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
        return buttonDataList.count
    }
    
    @IBAction func timeSegmentChange(_ sender: Any) {
        switch timeSegmentContoller.selectedSegmentIndex
        {
        case 0:
            //today
            self.buttonDataList.removeAll()
            loadUserDataToday()
            self.tableView.reloadData()
        case 1: // this week
            self.buttonDataList.removeAll()
            loadUserDataWeek()
            self.tableView.reloadData()
        case 2: // all time
            self.buttonDataList.removeAll()
            loadUserDataAll()
            self.tableView.reloadData()
            
        default:
            break
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            
            let buttonCell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! HistoryTableViewCell
            let button = buttonDataList[indexPath.row]
            
            //references - https://stackoverflow.com/questions/28598830/spacing-between-uitableviewcells/45515483
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 149))
            
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.clipsToBounds = true
            
            whiteRoundedView.layer.cornerRadius = 20
            whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
            whiteRoundedView.layer.shadowOpacity = 0.2
            
       
            
            buttonCell.contentView.addSubview(whiteRoundedView)
            buttonCell.contentView.sendSubviewToBack(whiteRoundedView)
            buttonCell.layer.cornerRadius = 10
            
            if(button.name == "No Face"){
                 buttonCell.nameTxt.text = "No Face Detected"
                
               
            } else {
                 buttonCell.nameTxt.text = button.name
               
            }
            if(button.name == "No Face" || button.name == "Unknown"){
                  buttonCell.addPerson.isHidden = false
            } else{
                  buttonCell.addPerson.isHidden = true
            }
           
            
            var time  = Date(timeIntervalSince1970: TimeInterval(button.time.seconds))
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd,yyyy HH:mm"
            
            
            var fTime = dateFormatterPrint.string(from: time)
            
            buttonCell.timeTxt.text = "\(fTime)"
            
            let email = Auth.auth().currentUser!.uid
            let imgUrl = "\(button.image_url)"
            //get the user's profile image
            let islandRef = storageRef.child(imgUrl)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                    // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    buttonCell.personImage.image =  self.resizeImage(image: UIImage(data: data!)!, targetSize: CGSize(width: 84, height: 82))
                    
                    
                    // contactCell.userImageView.image = image
                    buttonCell.personImage.layer.borderWidth = 1
                    buttonCell.personImage.layer.masksToBounds = false
                    buttonCell.personImage.layer.borderColor = UIColor.clear.cgColor
                    buttonCell.personImage.layer.cornerRadius = buttonCell.personImage.frame.height/2
                    buttonCell.personImage.clipsToBounds = true
                }
                
            }
            return buttonCell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        var selectedContact = buttonDataList[indexPath.row]
        if( selectedContact.name == "No Face" || selectedContact.name == "Unknown"){
            performSegue(withIdentifier: "addToContactSegue", sender: buttonDataList[indexPath.row])

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "addToContactSegue",
            let destination = segue.destination as? AddToContactVCViewController
            //let blogIndex = tableView.indexPathForSelectedRow?.row
        {
            let contact = sender as! ButtonData
            
            destination.buttonData = contact
        }
    }
  
    func loadUserDataToday(){
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
       
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        let start = calendar.date(from: components)!
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        
        let basicQuery = Firestore.firestore()
            .collection("DeviceData")
            .document(userID)
            .collection("pushData")
            .whereField("userId", isEqualTo: userID)
            .whereField("time", isGreaterThan: start)
            .whereField("time", isLessThan: end)
            .order(by: "time", descending: true)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for sensortDoc in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(ButtonData.self, from: sensortDoc.data())
                    self.buttonDataList.append(sData)
                    print(sData.name)
                } catch let error {
                    print(error)
                }
                
            }
            
            tempButtonData = self.buttonDataList
            self.tableView.reloadData()
            
        }
    }
    
    
    func loadUserDataWeek(){
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
        
      
        
        
        let actualStart = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        print(actualStart)
       
        let end = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date())!

        print(end)
        
        let basicQuery = Firestore.firestore()
            .collection("DeviceData")
            .document(userID)
            .collection("pushData")
            .whereField("userId", isEqualTo: userID)
            .whereField("time", isGreaterThan: end)
            .whereField("time", isLessThan: actualStart)
            .order(by: "time", descending: true)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for sensortDoc in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(ButtonData.self, from: sensortDoc.data())
                    self.buttonDataList.append(sData)
                    print(sData.name)
                } catch let error {
                    print(error)
                }
                
            }
            
            tempButtonData = self.buttonDataList
            self.tableView.reloadData()
            
        }
    }
    
    func loadUserDataAll(){
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
        
        
        
      
        
        let basicQuery = Firestore.firestore()
            .collection("DeviceData")
            .document(userID)
            .collection("pushData")
            .whereField("userId", isEqualTo: userID)
            .order(by: "time", descending: true)
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for sensortDoc in allDocuments {
                
                do {
                    
                    //decoding the json and storing it in a sensor object format
                    let sData = try FirestoreDecoder().decode(ButtonData.self, from: sensortDoc.data())
                    self.buttonDataList.append(sData)
                    print(sData.name)
                } catch let error {
                    print(error)
                }
                
            }
            
            tempButtonData = self.buttonDataList
            self.tableView.reloadData()
            
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
}
