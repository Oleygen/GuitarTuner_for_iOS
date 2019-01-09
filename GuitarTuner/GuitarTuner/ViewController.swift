//
//  ViewController.swift
//  GuitarTuner
//
//  Created by oleygen ua on 1/2/19.
//  Copyright © 2019 Gennady Oleynik. All rights reserved.
//

import UIKit
import AVFoundation


// https://www.objc.io/issues/24-audio/audio-dog-house/


// AKFrequencyTracker

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    
    var recordingSession: AVAudioSession?
    var audioRecord: AVAudioRecorder?
    var inputStreamManager: InputStreamManager?
    private let sampleRate = 44100.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // create recording session
        self.recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try self.recordingSession?.setPreferredSampleRate(sampleRate)
            try self.recordingSession?.setCategory(.record, mode: .measurement)
            try self.inputStreamManager = InputStreamManager(sampleRate: self.sampleRate, bitsPerChannel: 16)

        } catch
        {
            print("error when set values \(error)")
        }
        
        setupNotifications()
        

        // consider to use AAC Low Complexity Codecs
        // or smt faster with lower br?
        // bit rade mode? CBR/ABR/VBR
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recordingSession?.requestRecordPermission({ [weak self] allowed in
            if allowed
            {
                DispatchQueue.main.async {
                    self?.button.isEnabled = true
                }
                
            }
            else
            {
                print("user refuse permissions")
            }
        })
    }
    
    
    
    @IBAction func didClickButton(_ sender: UIButton) {
        if (sender.isSelected)
        {
            stopRecording()
        }
        else
        {
            startRecording()
        }
        
        
    }
    
    
    private func startRecording()
    {
        do {
            try self.recordingSession?.setActive(true)
            try self.inputStreamManager?.startStream()
            self.button.isSelected = true
            self.button.setTitle("Stop", for: .normal)
            print("actual SampleRate: \(self.recordingSession?.sampleRate ?? -1.0)")
        } catch
        {
            print("error when set active \(error)")
        }
    }
    
    private func stopRecording()
    {
        #warning ("Double set inactive if interruption comes in! Need to be tested!")
        do {
            try self.inputStreamManager?.stopStream()
            try self.recordingSession?.setActive(false, options: [AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation])
            self.button.isSelected = false
            self.button.setTitle("Start", for: .normal)
        } catch
        {
            print("error when set not active \(error)")
        }
    }
    
    private func setupNotifications()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: self.recordingSession)
    }
    
    @objc func handleInterruption(_ notification: Notification)
    {
        guard let info = notification.userInfo,
            let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeValue) else
        {
            print("Cant handle interruption")
            return
        }
        
        if type == .began
        {
            stopRecording()
        }
        else if type == .ended
        {
            guard let optionsValue =
                info[AVAudioSessionInterruptionOptionKey] as? UInt else
            {
                print("No interruption resume")
                    return
            }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
            
            if options.contains(.shouldResume) {
                startRecording()
            }
        }
    }
    
    
}

