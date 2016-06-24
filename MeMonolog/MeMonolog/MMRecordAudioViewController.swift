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
import Photos

class MMRecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    var videoURL = NSURL?()
    var videoPlayer = Player()
    let recorder = MMAudioRecorder()
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoView()
        recorder.prepareToRecordAudio()
    }
    
    private func setUpVideoView() {
        if videoURL != nil {
            videoPlayer.setUrl(videoURL!)
            videoPlayer.view.frame = videoView.bounds
            addChildViewController(videoPlayer)
            videoView.addSubview(videoPlayer.view)
            videoPlayer.fillMode = "AVLayerVideoGravityResizeAspect"
        }
    }
    
    //MARK: IBActions
    
    @IBAction func recordAudio(sender: UIButton) {
        videoPlayer.playFromBeginning()
        recorder.startRecording()
    }

    
    @IBAction func stopButton(sender: UIButton) {
        recorder.stopRecorder()
    }

    @IBAction func playAudio(sender: UIButton) {

        recorder.convertToPlaybackMode()
        
        do {
            videoPlayer.playFromBeginning()
            try audioPlayer = AVAudioPlayer(contentsOfURL:recorder.getAudioURL())
            audioPlayer.peakPowerForChannel(1)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.meteringEnabled = true
            audioPlayer.play()
        } catch {
            print("not working")
        }
    }
    
    @IBAction func mergeFiles(sender: UIButton) {
        
        let videoMerger = MMVideoMerger()
        
        videoMerger.mergeAudioAndVideo(video: videoURL!, audio: recorder.getAudioURL())
    }
    
}
