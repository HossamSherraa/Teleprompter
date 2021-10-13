//
//  MovieRecorder.swift
//  Teleprompter
//
//  Created by Hossam on 12/10/2021.
//

import AVFoundation


class MovieRecorder {
    static var isVideoShouldBeSaved : Bool = true
    internal init(exportURL: URL, delegate: AVCaptureFileOutputRecordingDelegate?) {
        self.exportURL = exportURL
        self.delegate = delegate
        config()
    }
    
    let exportURL : URL
    weak var delegate : AVCaptureFileOutputRecordingDelegate?
     var  session = AVCaptureSession()
    private let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    private let audioCaptureDevice = AVCaptureDevice.default(for: .audio)
    private lazy var inputDevice = try! AVCaptureDeviceInput(device: captureDevice!)
    private lazy var inputAudiDevice = try! AVCaptureDeviceInput(device: audioCaptureDevice!)
    private let outputMovie = AVCaptureMovieFileOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    
    
    func config(){
        
        outputMovie.movieFragmentInterval = CMTime.invalid
        session.beginConfiguration()
        session.addInput(inputDevice)
        session.addInput(inputAudiDevice)
        session.addOutput(outputMovie)
        session.commitConfiguration()
        session.startRunning()
        
        
        
    }
    
    
    func startRecording(){
        guard let delegate = self.delegate  else {return}
        outputMovie.startRecording(to: exportURL, recordingDelegate: delegate)
       
    }
    
    func endRecording(){
        outputMovie.stopRecording()
    }
    
   
}


