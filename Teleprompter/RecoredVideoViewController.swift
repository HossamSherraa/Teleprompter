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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewChilds()
        setViewControllerDelegate()
        loadScriptItemDetailsToTextView()
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
        textViewController.startMoving()
        cameraViewController.startRecording()
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
        print(recoredSize)
    }
    
    func didChangeSpeed(newValue: Float) {
        textViewController.setSpeedPrecentage(newValue)
    }
    
    
    
    
    
}
