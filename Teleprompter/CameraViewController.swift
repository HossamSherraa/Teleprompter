//
//  CameraViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit
import AVKit
import Photos
/*
 func getSessionPreviewLayer()
 func renderVideo(at url , aspectRatio : Aspect)->Any<Bool , Never>
 PassThrowsSubject finishedRecordingWith(Url)
 func startRecored
 func stopRecoredu
 */
import CameraKit_iOS

struct Aspect {
    let width : Int
    let height : Int
    
    var aspectRatio : CGFloat {
        return CGFloat(height) / CGFloat(width)
    }
}

protocol CaptureSessionManagerDelegate : AnyObject {
    func didCompleteRecordingAt(url : URL)
}
class CaptureSessionManager : NSObject , AVCaptureFileOutputRecordingDelegate{
    private var aspect : Aspect?
    
    weak var delegate : CaptureSessionManagerDelegate?
   lazy var  movieRecorder : MovieRecorder = MovieRecorder(exportURL: tempLinkURL, delegate: self)
    let composer = MovieComposer()
    
    var tempLinkURL : URL =  {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath =  documentsDirectory.appendingPathComponent("Temp\(Date().description).mp4")
        return filePath
    }()
    
    
    
    
    
   
    
    func startRecordingAt(aspect : Aspect){
        self.aspect = aspect
        movieRecorder.startRecording()
    }
    
    func stopRecording(){
        movieRecorder.endRecording()
    }
    
    
    func getPreviewLayer()->AVCaptureVideoPreviewLayer {
        let layer = AVCaptureVideoPreviewLayer(session: movieRecorder.session)
        layer.videoGravity = .resizeAspectFill
        return layer
    }
    
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
      
        //SaveToPhotos
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("r\(Date().description).mov")
        guard let aspect = self.aspect else {return}
        composer.addVideo(outputFileURL, aspect: aspect)
        let exportSession = composer.readyToComposeVideo(filePath)
        exportSession?.exportAsynchronously {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: filePath)
            }) { saved, error in
                if saved {
                    self.delegate?.didCompleteRecordingAt(url: filePath)
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                    
                }
            }
        }
        
    }
    
    
}
class CameraViewController : UIViewController , CaptureSessionManagerDelegate {
    var isRecording : Bool = false
    @IBOutlet weak var previewView: UIView!
    var captureSessionManager : CaptureSessionManager = CaptureSessionManager()
    
    var  previewLayer : AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSessionManager.delegate = self
        configPreviewView()
    }
    
    func configPreviewView(){
       let previewLayer =  captureSessionManager.getPreviewLayer()
        
        self.previewView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = previewView.bounds
        
        self.previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
    }
    
    func startRecording(){
      
        //manager.startRecording(completion :@escaping (URL)->Void)
      isRecording = true
        captureSessionManager.startRecordingAt(aspect: .init(width: 1, height: 1))
       
    }
    
    func stopRecording(){
        isRecording = false
        captureSessionManager.stopRecording()
        
    }
    
    
    internal func didCompleteRecordingAt(url : URL) {
        DispatchQueue.main.async {
                     let player = AVPlayer(url: url)
                     let vc = AVPlayerViewController()
                     vc.player = player
     
                     self.present(vc, animated: true) {
                         vc.player?.play()
//                        self.resetSession()
                        
                     }
                 }
    }
    func resetSession(){
        DispatchQueue.main.async {
        self.captureSessionManager = CaptureSessionManager()
        self.captureSessionManager.delegate = self
            self.previewLayer = self.captureSessionManager.getPreviewLayer()
            self.previewView.layoutIfNeeded()

        }
    }
    
    

}
