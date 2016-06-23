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
        print("Preferred Transform:\(videoAsset.preferredTransform)")
        //let mutableVideoTrack = AVMutableCompositionTrack()
        
        let audioAssetTrack = audioAsset.tracksWithMediaType(AVMediaTypeAudio).first
        let videoAssetTrack = videoAsset.tracksWithMediaType(AVMediaTypeVideo).first
        
        let mixComposition = AVMutableComposition()
        
        
//        let assetInstruction: AVMutableVideoCompositionLayerInstruction = layerInstructionAfterFixingOrientationForAsset(videoAsset, forTrack: mutableTrack, atTime: videoAsset.duration)
        
        
        let compositionCommentaryTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        
        do {
            try compositionCommentaryTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset.duration),
                                                           ofTrack: audioAssetTrack!,
                                                            atTime: kCMTimeZero)
        
        } catch {
            print("audio error")
        }
        
        let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        //        let mutableTrack = mixComposition.tracksWithMediaType(AVMediaTypeVideo).first
//        mutableTrack!.preferredTransform = videoAsset.preferredTransform

        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                videoAsset.duration),
                                                      ofTrack: videoAssetTrack!,
                                                       atTime: kCMTimeZero)
            
            compositionVideoTrack.preferredTransform = CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, 0.0, 0.0)
            
            print("actual Transform:\(compositionVideoTrack.preferredTransform)")

            
        } catch {
            print("video error")
        }
        
        //Video Instructions
        
//        var compositionInstructions = [AVMutableVideoCompositionInstruction]()
//    
//       let mutableTrack = mixComposition.tracksWithMediaType(AVMediaTypeVideo).first
//        mutableTrack!.preferredTransform = videoAsset.preferredTransform
//        
//        let videoComposition = AVMutableVideoComposition(propertiesOfAsset: videoAsset)
//        
//        
//        let assetInstruction: AVMutableVideoCompositionLayerInstruction = self.layerInstructionAfterFixingOrientationForAsset(videoAsset, forTrack: mutableTrack!, atTime: videoAsset.duration)
//        
//        let instruction = AVMutableVideoCompositionInstruction()
//        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
//        instruction.layerInstructions.append(assetInstruction)
//        
//        videoComposition.instructions = [instruction]
        
        
        //Export Asset
    
        
        let assetExport = AVAssetExportSession(asset: mixComposition, presetName:AVAssetExportPresetHighestQuality)
    
        
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
        
        assetExport?.outputFileType = AVFileTypeQuickTimeMovie
        assetExport?.outputURL = exportURL
        assetExport?.shouldOptimizeForNetworkUse = true
        
        
        assetExport?.exportAsynchronouslyWithCompletionHandler({
            
            //saves the video into photo library
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
    
    //http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
    
    func layerInstructionAfterFixingOrientationForAsset(inAsset:AVAsset, forTrack:AVMutableCompositionTrack, atTime:CMTime) -> AVMutableVideoCompositionLayerInstruction {
        
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: forTrack)
        let videoAssetTrack = inAsset.tracksWithMediaType(AVMediaTypeVideo).first
        var videoAssetOrientation = UIImageOrientation.Up
        var isPortrait = false
        let videoTransform: CGAffineTransform = (videoAssetTrack?.preferredTransform)!
    
        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
            videoAssetOrientation = UIImageOrientation.Right
            isPortrait = true
        }
        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
            videoAssetOrientation = UIImageOrientation.Left
            isPortrait = true
        }
        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
            videoAssetOrientation = UIImageOrientation.Up
        }
        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
            videoAssetOrientation = UIImageOrientation.Down
        }
        
        var firstAssetScaleToFitRatio = 320.0/(videoAssetTrack?.naturalSize.width)!
        
        var firstAssetScaleFactor = CGAffineTransform()
        
        if isPortrait {
            firstAssetScaleToFitRatio = 320.0/(videoAssetTrack?.naturalSize.height)!
            firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio, firstAssetScaleToFitRatio)
            videoLayerInstruction.setTransform(CGAffineTransformConcat((videoAssetTrack?.preferredTransform)!, firstAssetScaleFactor), atTime: kCMTimeZero)
        } else {
            firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio, firstAssetScaleToFitRatio)
            videoLayerInstruction.setTransform(CGAffineTransformConcat((videoAssetTrack?.preferredTransform)!, firstAssetScaleFactor), atTime: kCMTimeZero)
            videoLayerInstruction.setTransform(CGAffineTransformMakeTranslation(0, 160), atTime: kCMTimeZero)
        }
        
        videoLayerInstruction.setOpacity(0.0, atTime: atTime)
        
        return videoLayerInstruction
    }
    
    
    /*
     //FIXING ORIENTATION//
     
     - (AVMutableVideoCompositionLayerInstruction *)layerInstructionAfterFixingOrientationForAsset:(AVAsset *)inAsset
     forTrack:(AVMutableCompositionTrack *)inTrack
     atTime:(CMTime)inTime
     
     AVMutableVideoCompositionLayerInstruction *videolayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:inTrack];
     AVAssetTrack *videoAssetTrack = [[inAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     UIImageOrientation videoAssetOrientation_  = UIImageOrientationUp;
     BOOL  isVideoAssetPortrait_  = NO;
     CGAffineTransform videoTransform = videoAssetTrack.preferredTransform;
     
     if(videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0)  {videoAssetOrientation_= UIImageOrientationRight; isVideoAssetPortrait_ = YES;}
     if(videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0)  {videoAssetOrientation_ =  UIImageOrientationLeft; isVideoAssetPortrait_ = YES;}
     if(videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0)   {videoAssetOrientation_ =  UIImageOrientationUp;}
     if(videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0) {videoAssetOrientation_ = UIImageOrientationDown;}
     
     CGFloat FirstAssetScaleToFitRatio = 320.0 / videoAssetTrack.naturalSize.width;
     
     if(isVideoAssetPortrait_) {
     FirstAssetScaleToFitRatio = 320.0/videoAssetTrack.naturalSize.height;
     CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
     [videolayerInstruction setTransform:CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
     }else{
     CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
     [videolayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(videoAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
     }
     [videolayerInstruction setOpacity:0.0 atTime:inTime];
     return videolayerInstruction;
     }
     
     AVAssetTrack *assetTrack = [[inAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
     
     AVMutableCompositionTrack *mutableTrack = [mergeComposition mutableTrackCompatibleWithTrack:assetTrack];
     
     AVMutableVideoCompositionLayerInstruction *assetInstruction = [self layerInstructionAfterFixingOrientationForAsset:inAsset forTrack:myLocalVideoTrack atTime:videoTotalDuration];
     
    */
    
    
    
}
