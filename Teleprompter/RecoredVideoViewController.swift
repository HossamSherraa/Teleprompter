//
//  RecoredVideoViewController.swift
//  Teleprompter
//
//  Created by Hossam on 03/10/2021.
//

import UIKit

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
    func onPressRecored() {
        countViewController.start()
        countViewController.view.isHidden = false
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
    
    
    
    
    
}



extension RecoredVideoViewController : CountViewControllerDelegate {
    func countViewControllerDidFinishCounting() {
        countViewController.view.isHidden = true
        textViewController.startMoving()
        cameraViewController.startRecording()
    }
    
    
}

extension RecoredVideoViewController : CameraViewControllerDelegate {
    func cameraViewControllerNeedResetText() {
        textViewController.reset()
    }
    
    func cameraViewControllerStartLoading() {
        loadingViewController.view.isHidden = false
    }
    
    func cameraViewControllerEndLoading() {
        loadingViewController.view.isHidden = true
    }
    
    
}
