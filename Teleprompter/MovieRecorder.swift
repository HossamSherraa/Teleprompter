//
//  MovieRecorder.swift
//  Teleprompter
//
//  Created by Hossam on 12/10/2021.
//

import AVFoundation
import UIKit
import AVFAudio

protocol MovieRecorderDelegate : AVCaptureFileOutputRecordingDelegate {
    func audioMeteringDidUpdated(decibels : Float)
}
class MovieRecorder {
    static var isVideoShouldBeSaved : Bool = true
    var audioMeteringRecorder : AVAudioRecorder!
    internal init(exportURL: URL, delegate: MovieRecorderDelegate?) {
        self.exportURL = exportURL
        self.delegate = delegate
       configSession()
       configAudioMetering()
    }
    
    let exportURL : URL
    weak var delegate : MovieRecorderDelegate?
     var  session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private let audioCaptureDevice = AVCaptureDevice.default(for: .audio)
    private lazy var inputDevice = try! AVCaptureDeviceInput(device: captureDevice!)
    private lazy var inputAudiDevice = try! AVCaptureDeviceInput(device: audioCaptureDevice!)
    private let outputMovie = AVCaptureMovieFileOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    
    
    func configSession(){
        
        outputMovie.movieFragmentInterval = CMTime.invalid
        session.beginConfiguration()
        session.addInput(inputDevice)
        session.addInput(inputAudiDevice)
        session.addOutput(outputMovie)
        session.commitConfiguration()
        session.startRunning()

    }
    
    func configAudioMetering(){
        audioMeteringRecorder = buildAudioMeteringRecorder()
    }
    
    
    func startRecording(){
        guard let delegate = self.delegate  else {return}
        outputMovie.startRecording(to: exportURL, recordingDelegate: delegate)
        startAudioMetering()
        
       
       
    }
    
    func endRecording(){
        outputMovie.stopRecording()
        stopAudioMetering()
    }
    
    func startAudioMetering(){
        audioMeteringRecorder.record()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self ] _ in
            self?.audioMeteringRecorder.updateMeters()
            if let deciblesAvergePower = self?.audioMeteringRecorder.averagePower(forChannel: 0) {
                self?.delegate?.audioMeteringDidUpdated(decibels: deciblesAvergePower)

                print(deciblesAvergePower)
            }
        }
    }
    
    func stopAudioMetering(){
        audioMeteringRecorder.stop()
        audioMeteringRecorder.deleteRecording()
    }
    
   
    func getAudioTempURL() -> URL {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        return soundURL
    }
    
    
    func buildAudioMeteringRecorder()->AVAudioRecorder {
        let recordSettings = [ AVFormatIDKey : kAudioFormatAppleLossless,
                                       AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                                       AVEncoderBitRateKey: 320000,
                                       AVNumberOfChannelsKey : 2,
                                       AVSampleRateKey : 44100.0 ] as [String : Any]
         let audioRecorder = try! AVAudioRecorder(url: getAudioTempURL(), settings: recordSettings)
        audioRecorder.isMeteringEnabled = true
        return audioRecorder
    }
}


