//
//  ViewController.swift
//  MeMonolog
//
//  Created by Jamaal Sedayao on 6/3/16.
//  Copyright © 2016 Jamaal Sedayao. All rights reserved.
//

import UIKit
import CameraManager

enum Recorder {
    case Recording
    case Stopped
}

class MMVideoViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var recordingIcon: UIImageView!
    
    var recorder = Recorder.Stopped {
        didSet{print(recorder)}
    }
    
    var myVideoURL = NSURL()
    
    let cameraManager = CameraManager()
    let fileManager = NSFileManager.defaultManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
    }
    @IBOutlet weak var recordButton: UIButton!
    
    //MARK: Camera Methods
    
    private func setUpCamera() {
       
        cameraManager.cameraOutputMode = .VideoWithMic
        cameraManager.cameraDevice = .Front
                cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
        
        cameraManager.cameraOutputQuality = .High
        cameraManager.writeFilesToPhoneLibrary = true
        cameraManager.addPreviewLayerToView(self.cameraView)
        

    }

    @IBAction func record(sender: UIButton) {
        if recorder == .Stopped {
            recorder = .Recording
            cameraView.addSubview(recordingIcon)
            recordingIcon.hidden = false
            cameraView.layer.borderWidth = 1.0
            cameraView.layer.borderColor = UIColor.greenColor().CGColor
            recordButton.layer.backgroundColor = UIColor.redColor().CGColor
            
            cameraManager.startRecordingVideo()
        
        } else if recorder == .Recording {
            cameraView.layer.borderWidth = 0.0
            recordButton.layer.backgroundColor = UIColor(colorLiteralRed: 39/255, green: 198/255, blue: 52/255, alpha: 1).CGColor
            recordingIcon.hidden = true
            recorder = .Stopped
            
            cameraManager.stopRecordingVideo({(videoURL, error) -> Void in
                if let errorOccured = error {
                    self.cameraManager.showErrorBlock(erTitle: "Error occurred", erMessage: errorOccured.localizedDescription)
                } else {
                    self.myVideoURL = videoURL!
                    print(self.myVideoURL)
                }
                
            })
            
        }
    }
    
    // MARK: Prepare For Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "recordAudioID" {
            let nextVC = segue.destinationViewController as! MMRecordAudioViewController
            nextVC.videoURL = self.myVideoURL
        }
        
    }

}

