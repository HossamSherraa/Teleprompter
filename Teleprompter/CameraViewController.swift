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
var globalAspect : Aspect = RecoredSize.square.aspect
class CaptureSessionManager : NSObject , AVCaptureFileOutputRecordingDelegate{
    
    weak var delegate : CaptureSessionManagerDelegate?
    lazy var  movieRecorder : MovieRecorder = MovieRecorder(exportURL: tempLinkURL, delegate: self)
    let composer = MovieComposer()
    
    var tempLinkURL : URL =  {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath =  documentsDirectory.appendingPathComponent("Temp\(Date().description).mp4")
        return filePath
    }()
    
    
    
    
    
    
    
    func startRecordingAt(aspect : Aspect){
        globalAspect = aspect
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
        
        if MovieRecorder.isVideoShouldBeSaved {
            //SaveToPhotos
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
            let filePath = documentsDirectory.appendingPathComponent("r\(Date().description).mov")
            
            composer.addVideo(outputFileURL, aspect: globalAspect)
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
    
    
}
protocol CameraViewControllerDelegate : AnyObject{
    func cameraViewControllerStartLoading()
    func cameraViewControllerEndLoading()
    func cameraViewControllerNeedResetText()
}
class CameraViewController : UIViewController , CaptureSessionManagerDelegate {
    weak var delegate : CameraViewControllerDelegate?
    private var isRecording : Bool = false
    @IBOutlet private weak var previewView: UIView!
    private var captureSessionManager : CaptureSessionManager = CaptureSessionManager()
    private var  previewLayer : AVCaptureVideoPreviewLayer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSessionManager.delegate = self
        configPreviewView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetSession()
    }
    private  func configPreviewView(){
        let previewLayer =  captureSessionManager.getPreviewLayer()
        
        self.previewView.layer.addSublayer(previewLayer)
        self.previewLayer = previewLayer
        self.previewView.backgroundColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer?.frame = previewView.bounds
        setConstraintsHeightFor(aspect: globalAspect)
        
        self.previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
        
    }
    
    func startRecording(){
        
        //manager.startRecording(completion :@escaping (URL)->Void)
        isRecording = true
        captureSessionManager.startRecordingAt(aspect: globalAspect)
        
        
    }
    
    func stopRecording(){
        isRecording = false
        
        
        
        makeDicision(title: "Use This Video?") { [weak self] in
            MovieRecorder.isVideoShouldBeSaved = true
            self?.captureSessionManager.stopRecording()
            self?.delegate?.cameraViewControllerStartLoading()
            
        } onNo: { [weak self ] in
            MovieRecorder.isVideoShouldBeSaved = false
            self?.captureSessionManager.stopRecording()
            self?.delegate?.cameraViewControllerNeedResetText()
            
        }
        
        
    }
    
    
    internal func didCompleteRecordingAt(url : URL) {
        self.resetSession()
        DispatchQueue.main.async {[weak self] in
            guard let self = self else {return}
            let player = AVPlayer(url: url)
            let vc = VideoPlayerViewController()
            vc.player = player
            self.delegate?.cameraViewControllerEndLoading()
            self.present(vc, animated: true) {
                vc.player?.play()
            }
        }
        
        
        
    }
    private func resetSession(){
        captureSessionManager.movieRecorder.session.stopRunning()
        let newCaptureSessionManager = CaptureSessionManager()
        
        newCaptureSessionManager.delegate = self
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = newCaptureSessionManager.getPreviewLayer()
        self.captureSessionManager = newCaptureSessionManager
        
        self.previewView.layer.addSublayer(self.previewLayer!)
        self.previewLayer?.frame = self.previewView.bounds
        DispatchQueue.main.async { [weak self ] in
            
            self?.previewView.layoutIfNeeded()
            self?.previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.videoOrientation
            
            self?.setConstraintsHeightFor(aspect: globalAspect)
        }
        
    }
    
    
    
    
    
    
    
    
    var widthConstraints : NSLayoutConstraint?
    var heightConstraints : NSLayoutConstraint?
    
    private   func setConstraintsHeightFor(aspect : Aspect){
        widthConstraints?.isActive = false
        heightConstraints?.isActive = false
        print(UIDevice.current.orientation.rawValue)
        if view.frame.width < view.frame.height { //Port
            self.widthConstraints = self.previewView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.minimumSized)
            self.heightConstraints = self.previewView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.minimumSized * aspect.aspectRatio)
            
        }
        else {
            self.widthConstraints = self.previewView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.minimumSized * aspect.aspectRatio)
            self.heightConstraints = self.previewView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.minimumSized )
            
            
        }
        widthConstraints?.isActive = true
        heightConstraints?.isActive = true
        
        self.view.superview?.layoutIfNeeded()
        self.previewLayer?.frame = self.previewView.bounds
    }
    
    func setAspect(_ aspect : Aspect){
        globalAspect = aspect
        setConstraintsHeightFor(aspect: aspect)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
    
}

extension CGRect {
    var minimumSized : CGFloat {
        if width > height {
            return height
        }else {
            return width
        }
    }
}


class VideoPlayerViewController : AVPlayerViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isPlayingVideo = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isPlayingVideo = false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        .portrait
    }
}
