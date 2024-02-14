//
//  SettingsViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 6/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import FirebaseAuth


class SettingsViewController: UIViewController {

 
    @IBOutlet weak var photoGalleryView: UIView!
    @IBOutlet weak var helpView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

      viewSet()
    }
    
    
  
    func viewSet(){
        photoGalleryView.layer.masksToBounds = false
        photoGalleryView.clipsToBounds = true
        
        photoGalleryView.layer.cornerRadius = 10
        photoGalleryView.layer.shadowOffset = CGSize(width: -1, height: 1)
        photoGalleryView.layer.shadowOpacity = 0.2
        
        
        helpView.layer.masksToBounds = false
        helpView.clipsToBounds = true
        helpView.layer.cornerRadius = 10
        helpView.layer.shadowOffset = CGSize(width: -1, height: 1)
        helpView.layer.shadowOpacity = 0.2
    }
    
    @IBAction func helpButton(_ sender: Any) {
    }
    @IBAction func photoGalleryButton(_ sender: Any) {
    }
    
    @IBAction func logout(_ sender: Any) {
        
        try! Auth.auth().signOut()
        
        if let storyboard = self.storyboard {
            let vc = storyboard.instantiateViewController(withIdentifier: "loginView") as! LoginViewController
            self.present(vc, animated: false, completion: nil)
        }
    }

}
