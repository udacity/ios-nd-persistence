//
//  RecordSoundsViewController.swift
//  Pick Your Pitch
//
//  Created by Udacity on 1/5/15.
//  Copyright (c) 2014 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: Properties
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var shouldSegueToSoundPlayer = false
    
    // MARK: Outlets
    
    @IBOutlet weak var recordingInProgress: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    // MARK: Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        //Hide the stop button
        stopButton.isHidden = true
        recordButton.isEnabled = true
    }

    // MARK: Actions
    
    @IBAction func recordAudio(_ sender: UIButton) {
        // Update the UI
        stopButton.isHidden = false
        recordingInProgress.isHidden = false
        recordButton.isEnabled = false
        
        // Setup audio session
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
        } catch _ {
        }

        // Create a name for the file. This is the code that you are looking for
        let filename = "usersVoice.wav"
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let pathArray = [dirPath, filename]
        let fileURL = URL(string: pathArray.joined(separator: "/"))

        do {
            // Initialize and prepare the recorder
            audioRecorder = try AVAudioRecorder(url: fileURL!, settings: [String: AnyObject]())
        } catch _ {
        }
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true;
        audioRecorder.prepareToRecord()

        audioRecorder.record()
    }
    
    @IBAction func stopAudio(_ sender: UIButton) {
        recordingInProgress.isHidden = true
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance();
        do {
            try audioSession.setActive(false)
        } catch _ {
        }
        
        // This function stops the audio. We will then wait to hear back from the recorder,
        // through the audioRecorderDidFinishRecording method
    }
    
    // MARK: Audio Recorded
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {

        if flag {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.pathExtension)
            self.performSegue(withIdentifier: "stopRecording", sender: self)
        } else {
            print("Recording was not successful")
            recordButton.isEnabled = true
            stopButton.isHidden = true
        }
    }

    // MARK: Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "stopRecording" {
            let playSoundsVC:PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = recordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
