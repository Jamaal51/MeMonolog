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

class MMRecordAudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    var videoURL = NSURL?()
    var videoPlayer = Player()
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoView()
        
    }
    
    private func setUpAudioRecorder() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){[unowned self](allowed:Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()){
                    if allowed {
                        print("yes")
                        //self.loadRecordingUI()
                    } else {
                        print("fail")
                    }
                }
            }
            
        } catch {
            print("failed to record")
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().stringByAppendingString("recording.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Success")
        } else {
            print("Fail")
        }
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
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @IBAction func recordAudio(sender: UIButton) {
        videoPlayer.playFromBeginning()
        startRecording()
    }
    

    
    
    
}
