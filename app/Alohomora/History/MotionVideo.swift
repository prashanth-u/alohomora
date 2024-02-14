//
//  MotionVideo.swift
//  Alohomora
//
//  Created by Poornima Sivakumar on 8/11/19.
//  Copyright © 2019 Poornima Sivakumar. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Firebase

class MotionVideo: UIViewController {
    
    @IBOutlet weak var timeTxt: UILabel!
    var motionObj: Motion?
    var storageRef: StorageReference!
    var db: Firestore!
    var userID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage()
        storageRef = storage.reference()
        userID = Auth.auth().currentUser!.uid
        
        timeTxt.text = "\(motionObj!.time.dateValue())"
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        return true
    }
    
    @IBAction func playVideo(_ sender: Any) {
        
        
        // Create a reference to the file you want to download
        let starsRef = storageRef.child(motionObj!.video_url)
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = paths.appendingPathComponent(motionObj!.video_file)
        
        // Create local filesystem URL
        //  let localURL = URL(string: "path/to/image")!
        
        // Download to the local filesystem
        let downloadTask = starsRef.write(toFile: filename) { url, error in
            if let error = error {
                // Uh-oh, an error occurred!
            } else {
                print(url)
                print("success!!!!")
                //            guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_adv_example_hevc/master.m3u8") else {
                //                return
                //            }
                //ref - https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos
                // Create an AVPlayer, passing it the HTTP Live Streaming URL.
                let player = AVPlayer(url: url!)
                
                // Create a new AVPlayerViewController and pass it a reference to the player.
                let controller = AVPlayerViewController()
                controller.player = player
                
                // Modally present the player and call the player's play() method when complete.
                self.present(controller, animated: true) {
                    player.play()
                }
                // Local file URL for "images/island.jpg" is returned
            }
        }
        
        
        
        
        
    }
}
