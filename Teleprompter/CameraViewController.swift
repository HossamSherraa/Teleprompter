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

class CaptureSessionManager {
    let session = CKFVideoSession(position: .front)
    let composer = MovieComposer()
    
    var tempLinkURL : URL =  {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath =  documentsDirectory.appendingPathComponent("Temp\(Date().description).mp4")
        return filePath
    }()
    
    
    
    
    
   
    
    func startRecordingAt(url : URL , aspect : Aspect , completion : @escaping (URL)->Void ){
        session.record(url: tempLinkURL, { fullVideoSizeUrl in
            self.composer.addVideo(fullVideoSizeUrl, aspect: aspect)
            let exportSession = self.composer.readyToComposeVideo(url)
            exportSession?.exportAsynchronously {
                completion(url)
            }
            
        }, error: {error in
            print(error)
        })
    }
    
    func stopRecording(){
        session.stopRecording()
    }
    
    
    func getPreviewView()->CKFPreviewView {
        let previewView = CKFPreviewView(frame: .zero)
        previewView.session = session
        return previewView
    }
    
    
}
class CameraViewController : UIViewController {
    var isRecording : Bool = false
    @IBOutlet weak var previewView: UIView!
    var captureSessionManager : CaptureSessionManager = CaptureSessionManager()
    private var _previewView : CKFPreviewView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configPreviewView()
    }
    
    func configPreviewView(){
       let previewView =  captureSessionManager.getPreviewView()
        self._previewView = previewView
        self.previewView.addSubview(previewView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _previewView.frame = previewView.bounds
        
        _previewView.previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
    }
    
    func startRecording(){
      
      isRecording = true
       
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent("r\(Date().description).mp4")
        
        captureSessionManager.startRecordingAt(url: filePath, aspect: .init(width: 1, height: 1)) {[weak self] url in
            guard let self = self else {return}
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

                    
                }
            }
            
            
            DispatchQueue.main.async {
                let player = AVPlayer(url: url)
                let vc = AVPlayerViewController()
                vc.player = player

                self.present(vc, animated: true) {
                    vc.player?.play()
                }
            }
            self.resetSession()
        }
    }
    
    func stopRecording(){
        captureSessionManager.stopRecording()
        
    }
    
    func resetSession(){
        self.captureSessionManager = CaptureSessionManager()
        DispatchQueue.main.async {
            self._previewView.session  = self.captureSessionManager.session
            self._previewView.layoutIfNeeded()
            
        }
    }
    
    

}
