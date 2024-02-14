//
//  HistoryMenuViewController.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 7/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit

class HistoryMenuViewController: UIViewController {

    @IBOutlet weak var motionView: UIView!
    @IBOutlet weak var doorbellView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        addShadow()
        // Do any additional setup after loading the view.
    }
    

    func addShadow(){
        
        motionView.layer.cornerRadius = 20.0
        motionView.layer.shadowColor = UIColor.gray.cgColor
        motionView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        motionView.layer.shadowRadius = 12.0
        motionView.layer.shadowOpacity = 0.7
        
        doorbellView.layer.cornerRadius = 20.0
        doorbellView.layer.shadowColor = UIColor.gray.cgColor
        doorbellView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        doorbellView.layer.shadowRadius = 12.0
        doorbellView.layer.shadowOpacity = 0.7
    }

}
