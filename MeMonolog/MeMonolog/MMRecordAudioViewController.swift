//
//  MMRecordAudioViewController.swift
//  MeMonolog
//
//  Created by Jamaal Sedayao on 6/4/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import UIKit
import Player
import AVFoundation

class MMRecordAudioViewController: UIViewController {
    
    var videoURL: NSURL?
    var videoPlayer = Player()
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoView()
        
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //videoPlayer.playFromBeginning()
    }
    
    func setUpVideoView() {
            videoPlayer.setUrl(videoURL!)
            videoPlayer.view.frame = videoView.bounds
            addChildViewController(videoPlayer)
            videoView.addSubview(videoPlayer.view)
            videoPlayer.fillMode = "AVLayerVideoGravityResizeAspect"
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        videoPlayer.playFromBeginning()
    }
}
