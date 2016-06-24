//
//  MMVideoMerge.swift
//  MeMonolog
//
//  Created by Jamaal Sedayao on 6/23/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

class MMVideoMerger {

    var audioAsset = AVURLAsset?()
    var videoAsset = AVURLAsset?()
    var assetExport = AVAssetExportSession?()
    
    private let mixComposition = AVMutableComposition()

    internal func mergeAudioAndVideo(video video:NSURL, audio:NSURL) {
        
        audioAsset = AVURLAsset(URL: audio)
        videoAsset = AVURLAsset(URL: video)
        
        //print("Preferred Transform:\(videoAsset!.preferredTransform)")
        
        let audioAssetTrack = audioAsset!.tracksWithMediaType(AVMediaTypeAudio).first
        let videoAssetTrack = videoAsset!.tracksWithMediaType(AVMediaTypeVideo).first
        
        let compositionCommentaryTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let compositionVideoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try compositionCommentaryTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAsset!.duration),
                                                           ofTrack: audioAssetTrack!,
                                                           atTime: kCMTimeZero)
        } catch {
            print("audio error")
        }
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero,
                videoAsset!.duration),
                                                      ofTrack: videoAssetTrack!,
                                                      atTime: kCMTimeZero)
            
            compositionVideoTrack.preferredTransform = CGAffineTransformMake(0.0, 1.0, -1.0, 0.0, 0.0, 0.0)
            
            print("actual Transform:\(compositionVideoTrack.preferredTransform)")
            
        } catch {
            print("video error")
        }
        
        //Export Asset
        
        assetExport = AVAssetExportSession(asset: mixComposition, presetName:AVAssetExportPresetHighestQuality)
        
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
                PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL((self.assetExport?.outputURL)!)
                }, completionHandler: { (success, error) in
                    if (success) {
                        print("Success");
                    }
                    else {
                        print("write error")
                    }
            })
        })
    }
}








//    //http://stackoverflow.com/questions/12136841/avmutablevideocomposition-rotated-video-captured-in-portrait-mode
//    
//    private func layerInstructionAfterFixingOrientationForAsset(inAsset:AVAsset, forTrack:AVMutableCompositionTrack, atTime:CMTime) -> AVMutableVideoCompositionLayerInstruction {
//        
//        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: forTrack)
//        let videoAssetTrack = inAsset.tracksWithMediaType(AVMediaTypeVideo).first
//        var videoAssetOrientation = UIImageOrientation.Up
//        var isPortrait = false
//        let videoTransform: CGAffineTransform = (videoAssetTrack?.preferredTransform)!
//        
//        if videoTransform.a == 0 && videoTransform.b == 1.0 && videoTransform.c == -1.0 && videoTransform.d == 0 {
//            videoAssetOrientation = UIImageOrientation.Right
//            isPortrait = true
//        }
//        if videoTransform.a == 0 && videoTransform.b == -1.0 && videoTransform.c == 1.0 && videoTransform.d == 0 {
//            videoAssetOrientation = UIImageOrientation.Left
//            isPortrait = true
//        }
//        if videoTransform.a == 1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == 1.0 {
//            videoAssetOrientation = UIImageOrientation.Up
//        }
//        if videoTransform.a == -1.0 && videoTransform.b == 0 && videoTransform.c == 0 && videoTransform.d == -1.0 {
//            videoAssetOrientation = UIImageOrientation.Down
//        }
//        
//        var firstAssetScaleToFitRatio = 320.0/(videoAssetTrack?.naturalSize.width)!
//        
//        var firstAssetScaleFactor = CGAffineTransform()
//        
//        if isPortrait {
//            firstAssetScaleToFitRatio = 320.0/(videoAssetTrack?.naturalSize.height)!
//            firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio, firstAssetScaleToFitRatio)
//            videoLayerInstruction.setTransform(CGAffineTransformConcat((videoAssetTrack?.preferredTransform)!, firstAssetScaleFactor), atTime: kCMTimeZero)
//        } else {
//            firstAssetScaleFactor = CGAffineTransformMakeScale(firstAssetScaleToFitRatio, firstAssetScaleToFitRatio)
//            videoLayerInstruction.setTransform(CGAffineTransformConcat((videoAssetTrack?.preferredTransform)!, firstAssetScaleFactor), atTime: kCMTimeZero)
//            videoLayerInstruction.setTransform(CGAffineTransformMakeTranslation(0, 160), atTime: kCMTimeZero)
//        }
//        
//        videoLayerInstruction.setOpacity(0.0, atTime: atTime)
//        
//        return videoLayerInstruction
//    }
    
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
