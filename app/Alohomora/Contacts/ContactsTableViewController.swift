//
//  ContactsTableViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 5/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase
import CodableFirebase


var tempContactList: [Contacts] = []
class ContactsTableViewController: UITableViewController {
    
    let SECTION_PARTY = 0;
    let SECTION_COUNT = 1;
    let CELL = "contactsCell"
    var storageRef: StorageReference!
    var contactList: [Contacts] = []
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
        self.contactList.removeAll()
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
        return contactList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
           
        let contactCell = tableView.dequeueReusableCell(withIdentifier: CELL, for: indexPath) as! ContactsTableViewCell
        let contact = contactList[indexPath.row]
        
            //references - https://stackoverflow.com/questions/28598830/spacing-between-uitableviewcells/45515483
            let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: 149))
            
            whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 0.8])
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.clipsToBounds = true

            whiteRoundedView.layer.cornerRadius = 20
            whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
            whiteRoundedView.layer.shadowOpacity = 0.2
            
            contactCell.contentView.addSubview(whiteRoundedView)
            contactCell.contentView.sendSubviewToBack(whiteRoundedView)
            
            
             contactCell.layer.cornerRadius = 10
            
        contactCell.nameTxt.text = contact.firstName
        if(contact.trustedContact == 0){
            contactCell.isTrustedImageView.isHidden = true
        }
            let email = Auth.auth().currentUser!.uid
            let imgUrl = "\(email)/trusted/\(contact.imgUrl).jpeg"
        //get the user's profile image
            let islandRef = storageRef.child(imgUrl)
            islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error {
                    print(error)
                } else {
                     // Data for "images/island.jpg" is returned
                    let image = UIImage(data: data!)
                    contactCell.userImageView.image =  self.resizeImage(image: UIImage(data: data!)!, targetSize: CGSize(width: 84, height: 82))


                   // contactCell.userImageView.image = image
                    contactCell.userImageView.layer.borderWidth = 1
                    contactCell.userImageView.layer.masksToBounds = false
                    contactCell.userImageView.layer.borderColor = UIColor.clear.cgColor
                    contactCell.userImageView.layer.cornerRadius = contactCell.userImageView.frame.height/2
                    contactCell.userImageView.clipsToBounds = true
                }

            }
        return contactCell
    }
            
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//
//        return false
//    }
//
    override func tableView(_ tableView: UITableView, commit editingStyle:
        UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete  {
            let contact = contactList[indexPath.row]
            let userId = Auth.auth().currentUser!.uid
            let name =  "\(contact.firstName)_\(contact.lastName)"
            
            db.collection("UserData").document(userId).collection("Contacts").document(name).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    
                    print("Document successfully removed!")
                    
                }
            }

            let desertRef = storageRef.child(contact.imgPath)
            
            // Delete the file
            desertRef.delete { error in
                if let error = error {
                     print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    
                }
            }
            
            self.contactList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "viewContactSegue", sender: contactList[indexPath.row])
    }

    
    func loadUserData(){
          print("DATAaaaa")
        //getting data from firebase and ordering it by time
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
        let userID = Auth.auth().currentUser!.uid
        print(userID)
        let basicQuery = Firestore.firestore().collection("UserData").document(userID).collection("Contacts")
        .order(by: "firstName", descending: false)
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
                    let sData = try FirestoreDecoder().decode(Contacts.self, from: sensortDoc.data())
                    self.contactList.append(sData)
                    print(sData.firstName)
                } catch let error {
                    print(error)
                }
                
            }
            
            tempContactList = self.contactList
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if  segue.identifier == "viewContactSegue",
            let destination = segue.destination as? ContactDetailsViewController
            //let blogIndex = tableView.indexPathForSelectedRow?.row
        {
            let contact = sender as! Contacts
            
            destination.contactObj = contact
        }
    }

}
