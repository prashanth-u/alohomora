//
//  GalleryCollectionViewController.swift
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

//private let reuseIdentifier = "Cell"

class GalleryCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var storageRef: StorageReference!
    var customImageList: [ImageData] = []
    var db: Firestore!
    private let reuseIdentifier = "imageCell"
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    private let itemsPerRow: CGFloat = 3
    
    var imageList = [UIImage]()
    var imagePathList = [String]()
    var userId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        let storage = Storage.storage()
        storageRef = storage.reference()
        userId = Auth.auth().currentUser!.uid

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         getImageData()
    }
    
  
    func getImageData(){
         var custList: [ImageData] = []
        //references: https://codelabs.developers.google.com/codelabs/firebase-cloud-firestore-workshop-swift/index.html?index=..%2F..index#3
        let userID = Auth.auth().currentUser!.uid
        let basicQuery = Firestore.firestore().collection("UserData").document(userID).collection("Images")
        basicQuery.getDocuments { (snapshot, error) in
            if let error = error {
                print("Oh no! Got an error! \(error.localizedDescription)")
                return
            }
            guard let snapshot = snapshot else { return }
            let allDocuments = snapshot.documents
            for sensortDoc in allDocuments {
                do {
                    let sData = try FirestoreDecoder().decode(ImageData.self, from: sensortDoc.data())
                    custList.append(sData)
                    print("yay-1")
                } catch let error {
                    print("oops")
                    print(error)
                }
                
            }
                print(custList.count)
            self.customImageList = custList
            
            if(custList.count > 0) {
                for data in custList {
                    let fileName = data.imgPath
                    
                    if(self.imagePathList.contains(fileName)) {
                        print("Image already loaded in. Skipping image")
                        continue
                    }
                    
                    let fName = "\(fileName).jpeg"
                    var image: UIImage?
                    //get the user's profile image
                    let islandRef = self.storageRef.child(fName)
                    islandRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error)
                        } else {
                            print("yay-99")
                            image = UIImage(data: data!)
                            self.imageList.append(image!)
                            self.imagePathList.append(fileName)
                            self.collectionView!.reloadSections([0])
                            
                            
                        }
                        
                    }

                }
            }
        }
      
    }
    
    
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imageList.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        
        cell.backgroundColor = UIColor.lightGray
        cell.imageView.image = imageList[indexPath.row]
    
    
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath:
        IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, insetForSectionAt
        section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt
        section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    
    

}
