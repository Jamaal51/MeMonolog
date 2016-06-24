//
//  MMAudioRecorder.swift
//  MeMonolog
//
//  Created by Jamaal Sedayao on 6/24/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import Foundation
import AVFoundation

class MMAudioRecorder: NSObject, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    var recordingSession = AVAudioSession.sharedInstance()
    
    var audioURL = NSURL?()

    func prepareToRecordAudio(){
        
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
            
            let audioURL = self.directoryURL()
            self.audioURL = audioURL
            
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
                self.audioURL = self.directoryURL()
            } catch {
                print("doesnt record")
                self.finishRecording(success: false)
            }
        }
    }
    
    func getAudioURL()-> NSURL {
        return self.audioURL!
    }
    
    func stopRecorder(){
        audioRecorder.stop()
    }
    
    func convertToPlaybackMode(){
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("no change")
        }
    }
    
    private func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            print("Success")
        } else {
            print("Fail")
        }
    }
    
    @objc internal func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    private func directoryURL() -> NSURL? {
        let fileManager = NSFileManager.defaultManager()
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.URLByAppendingPathComponent("sound.m4a")
        return soundURL
    }
    
}