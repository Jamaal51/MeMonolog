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
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    var audioPlayer = AVAudioPlayer()
    var recordedAudioURL = NSURL?()
    
    @IBOutlet weak var videoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpVideoView()
        setUpAudioRecorder()
    }
    
    private func setUpAudioRecorder() {
        //audioRecorder = AVAudioRecorder()
            recordingSession = AVAudioSession.sharedInstance()
      
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){(allowed:Bool) -> Void in
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
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { 
            let audioFilename = self.getDocumentsDirectory().stringByAppendingString("recording.m4a")
            let audioURL = NSURL(fileURLWithPath: audioFilename)
            self.recordedAudioURL = audioURL
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1 as NSNumber,
                AVEncoderAudioQualityKey: AVAudioQuality.Max.rawValue,
                AVEncoderBitRateKey: 128000
            ]
            
            do {
                self.audioRecorder = try AVAudioRecorder(URL: self.directoryURL()!, settings: settings)
                self.audioRecorder.delegate = self
                self.audioRecorder.record()
                print("Recording:\(self.audioRecorder.record())")
                self.recordedAudioURL = self.directoryURL()
            } catch {
                print("doesnt record")
                self.finishRecording(success: false)
            }
        }
    
    }
    
    func getDocumentsDirectory() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        return soundURL
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
        //print("Recording:\(audioRecorder!.recording)")
    }
    
    @IBAction func stopButton(sender: UIButton) {
        audioRecorder.stop()
    }

    @IBAction func playAudio(sender: UIButton) {
        
        do {
         try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("no change")
        }
//        let soundString = getDocumentsDirectory()
//        recordedAudioURL = NSURL(fileURLWithPath: soundString)
//        
//        let path = NSBundle.mainBundle().pathForResource(getDocumentsDirectory().stringByAppendingString("recording.m4a"), ofType:nil)
//        let url = NSURL(fileURLWithPath: path!)
        
        print(recordedAudioURL)
        print(audioPlayer)
        
        do {
            videoPlayer.playFromBeginning()
            try audioPlayer = AVAudioPlayer(contentsOfURL:recordedAudioURL!)
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
        
        mergeAudioAndVideo(video: videoURL!, audio: self.recordedAudioURL!)
    }
    
    
    func mergeAudioAndVideo(video video:NSURL, audio:NSURL) -> Int {
        
        let audioAsset = AVURLAsset(URL: audio)
        let videoAsset = AVURLAsset(URL: video)
        videoAsset = c
        
        let mixComposition = AVMutableComposition()
        
        let compositionCommentaryTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try compositionCommentaryTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset.duration),
                                                           ofTrack: audioAsset.tracksWithMediaType(AVMediaTypeAudio).first!,
                                                            atTime: kCMTimeZero)
        } catch {
            print("audio error")
        }
        
        let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                videoAsset.duration),
                                                      ofTrack: videoAsset.tracksWithMediaType(AVMediaTypeVideo).first!,
                                                       atTime: kCMTimeZero)
        } catch {
            print("video error")
        }
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetPassthrough)
        
        let videoName = "export.mov"
        
        let exportPath = NSTemporaryDirectory().stringByAppendingString(videoName)
        let exportURL = NSURL(fileURLWithPath: exportPath)
        
        if NSFileManager.defaultManager().fileExistsAtPath(exportPath){
            do {
                try NSFileManager.defaultManager().removeItemAtPath(exportPath)
            }catch{
                print("file error")
            }
        }
        
        assetExport?.outputFileType = "com.apple.quicktime-movie"
        print("File type: \(assetExport?.outputFileType)")
        assetExport?.outputURL = exportURL
        assetExport?.shouldOptimizeForNetworkUse = true
        
        assetExport?.exportAsynchronouslyWithCompletionHandler({ 
            print("works")
            print(assetExport?.outputURL)
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL((assetExport?.outputURL)!)
                }, completionHandler: { (success, error) in
                    if (success) {
                        print("Success");
                    }
                    else {
                        print("write error")
                    }
            })
        })
        return 0
    }

}
