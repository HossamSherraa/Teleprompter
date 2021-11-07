//
//  RecoredVideoViewController.swift
//  Teleprompter
//
//  Created by Hossam on 03/10/2021.
//

import UIKit

var isPlayingVideo : Bool = false
class RecoredVideoViewController : UIViewController {
    var scriptItem : ScriptItem? = nil
    let cameraViewController = UIViewController.instantiateViewController(using: "CameraViewController", type: CameraViewController.self)
    let controlPanelViewController = UIViewController.instantiateViewController(using: "ControlPanelViewController", type: ControlPanelViewController.self)
    let textViewController = UIViewController.instantiateViewController(using: "TextViewController", type: TextViewController.self)
    let loadingViewController = UIViewController.instantiateViewController(using: "LoadingViewController", type: UIViewController.self)
    let countViewController = UIViewController.instantiateViewController(using: "CountViewController", type: CountViewController.self)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewChilds()
        setViewControllerDelegate()
        loadScriptItemDetailsToTextView()
        
        loadingViewController.view.isHidden = true
        countViewController.view.isHidden = true
        
        cameraViewController.delegate = self
        countViewController.delegate = self
        
        configViewForSize(view.frame.size)
        startObserveUserTalks()
    }
    
    private func loadScriptItemDetailsToTextView(){
        if let scriptItem = scriptItem {
            self.textViewController.setText(text: scriptItem.scriptContent)
        }
    }
    func buildViewChilds(){
        
       let cameraView = add(cameraViewController)
       let controlPanelView = add(controlPanelViewController)
       let textView = add(textViewController)
       let loadingView = add(loadingViewController)
       let countView = add(countViewController)
        
        NSLayoutConstraint.activate([
            
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor) ,
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: cameraView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor),
            
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.topAnchor.constraint(equalTo: view.topAnchor),
            view.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
           
           
            
            controlPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlPanelView.topAnchor.constraint(equalTo: textView.bottomAnchor ),
            view.trailingAnchor.constraint(equalTo: controlPanelView.trailingAnchor),
            controlPanelView.bottomAnchor.constraint(equalTo: view.bottomAnchor) ,
            
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            countView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            countView.topAnchor.constraint(equalTo: view.topAnchor),
            countView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            countView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            
            
           
        
        ])
    }
    
    func setViewControllerDelegate(){
        controlPanelViewController.delegate = self
    }
 
    func startObserveUserTalks(){
        NotificationCenter.default.addObserver(self, selector: #selector(didStartTalking), name: .userDidStartTalking, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didStopTalking), name: .userDidStopTalking, object: nil)
    }
    
    @objc
    func didStartTalking(){
        textViewController.startMoving()
    }
    
    @objc
    func didStopTalking(){
        textViewController.stopMoving()
    }
    
    
    
}

extension UIViewController {
    static func instantiateViewController<T>(using identifier : String , type : T.Type , storyboardName : String = "Main")-> T {
        UIStoryboard.init(name: storyboardName, bundle: nil).instantiateViewController(withIdentifier: identifier) as! T
    }
}


extension UIViewController {
    func add(_ child: UIViewController)->UIView {
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        child.didMove(toParent: self)
        return child.view
    }

    
}


//MARK:- ControlPanelDelegate
extension RecoredVideoViewController : ControlPanelDelegate {
    func onPressStopTest() {
        textViewController.reset()
        textViewController.stopMoving()
    }
    
    func onPressRecored() {
        countViewController.start()
        countViewController.view.isHidden = false
        controlPanelViewController.hideAllButtons()
        controlPanelViewController.hideAllControlButtons()
    }
    
    func onPressStopRecored() {
        textViewController.stopMoving()
        cameraViewController.stopRecording()
    }
    
    func onPressTest() {
        if textViewController.isMoving {
            textViewController.stopMoving()
        }else {
            textViewController.startMoving()
        }
    }
    
    
    
    func didChangeFontSize(newValue: Float) {
        textViewController.setTextSize(size: CGFloat(newValue))
    }
    
    func didChangeRecoredSize(recoredSize: RecoredSize) {
        cameraViewController.setAspect(recoredSize.aspect)
    }
    
    func didChangeSpeed(newValue: Float) {
        textViewController.setSpeedPrecentage(newValue)
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configViewForSize(size)
    }
    
    
    
    func configViewForSize(_ size : CGSize) {
        if isPortraint(size: size){
            self.controlPanelViewController.presentButtonsForPortraitMode()
        }else {
            self.controlPanelViewController.presentButtonsForLandscapeMode()
            self.cameraViewController.setAspect(RecoredSize.story.aspect)
        }
    }
    
    
}



extension RecoredVideoViewController : CountViewControllerDelegate {
    func countViewControllerDidFinishCounting() {
        countViewController.view.isHidden = true
        cameraViewController.startRecording()
    }
    
    
}

extension RecoredVideoViewController : CameraViewControllerDelegate {
    func cameraViewControllerNeedReset() {
        textViewController.reset()
        if isPortraint(size: view.frame.size) {
            controlPanelViewController.presentButtonsForPortraitMode()
        }else {
            controlPanelViewController.presentButtonsForLandscapeMode()
        }
    }
    
    func cameraViewControllerStartLoading() {
        loadingViewController.view.isHidden = false
    }
    
    func cameraViewControllerEndLoading() {
        loadingViewController.view.isHidden = true
        controlPanelViewController.presentAllControlButtons()
        if isPortraint(size: view.frame.size){
            controlPanelViewController.presentButtonsForPortraitMode()
        }else {
            controlPanelViewController.presentButtonsForLandscapeMode()
        }
    }
    
    
}
func isPortraint(size : CGSize)->Bool{
    size.width < size.height //THIS PORTRAIT
}
