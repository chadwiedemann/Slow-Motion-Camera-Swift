//
//  VideoPlayerViewController.swift
//  Slow Motion Camera Swift
//
//  Created by Chad Wiedemann on 10/17/16.
//  Copyright © 2016 Chad Wiedemann. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import QuartzCore
import MobileCoreServices


class VideoPlayerViewController: UIViewController {

    var videoURLString : String?
    var player : AVPlayer?
    var videoURL : NSURL?
    @IBOutlet weak var onOffPositionSwitch: UISwitch!
    @IBOutlet weak var regularSloLabel: UILabel!
    @IBOutlet weak var sloMoSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        self.videoURL = NSURL(fileURLWithPath: self.videoURLString!)
        self.player = AVPlayer(url: self.videoURL as! URL)
        let playerLayer = AVPlayerLayer(player: self.player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        self.navigationController?.title = "Regular Speed"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func playButton(_ sender: AnyObject) {
        if self.onOffPositionSwitch.isOn{
            self.player?.rate = 0.1
        }else{
            self.player?.rate = 1
        }
    }

    @IBAction func pauseButton(_ sender: AnyObject) {
        self.player?.pause()
    }
    
    @IBAction func slowMotionSwitch(_ sender: AnyObject) {
        if self.sloMoSwitch.isOn{
            self.regularSloLabel.text = "Slow Motion"
        }else{
            self.regularSloLabel.text = "Regular Speed"
        }
    }
}
