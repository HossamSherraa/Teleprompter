//
//  ControlPanelViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit
enum RecoredSize {
    case post
    case story
    case square
    
    var aspect : Aspect {
        switch self {
        case .post :  return .init(width: 3, height: 4)
        case .square : return .init(width: 1, height: 1)
        case .story : return .init(width: 9, height: 16)
        }
    }
}
protocol ControlPanelDelegate : AnyObject {
    func didChangeFontSize(newValue : Float)
    func didChangeRecoredSize(recoredSize:RecoredSize)
    func didChangeSpeed(newValue : Float)
    func onPressTest()
    func onPressStopTest()
    func onPressRecored()
    func onPressStopRecored()
}
class ControlPanelViewController : UIViewController {
    @IBOutlet weak var fontSizeView: UIView!
    @IBOutlet weak var recordSizeView: UIStackView!
    @IBOutlet weak var speedSizeView: UIView!
    
   
    @IBOutlet weak var changeTextSizeButton: UIButton!
    
    @IBOutlet weak var changeSpeedButton: UIButton!
    
    @IBOutlet weak var changeRecordSizeButton: UIButton!
    @IBOutlet weak var videoRecordSizeButton: UIButton!
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    @IBOutlet weak var postButton: UIButton!
    
    @IBOutlet weak var storyButton: UIButton!
    
    @IBOutlet weak var squareButton: UIButton!
    
    @IBOutlet weak var fontSizeBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var speedBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var recoredSizeBottomConstraints: NSLayoutConstraint!
    
    weak var delegate : ControlPanelDelegate?
    
    private var isTesing : Bool = false
    
    private var isRecording : Bool = false
    
   
    let verticalSpaceForShowStateExtentionButtons : CGFloat = 20
    let verticalSpaceForHideStateExtentionButtons : CGFloat = -90
    
    //OPENED
    @IBAction func onPressRecord(_ sender: UIButton) {
        
        if isRecording {
            isRecording = false
            delegate?.onPressStopRecored()
            sender.setImage(UIImage(named: "telep_video_start"), for: .normal)
        }else {
            isRecording = true
            delegate?.onPressRecored()
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
                
               sender.setImage(UIImage(named: "telep_video_stop"), for: .normal)
            }
        }
        
    }
    @IBAction func onPressText(_ sender: Any) {
        if fontSizeView.isHidden {
        fontSizeView.unhide()
        recordSizeView.hide()
            speedSizeView.hide()
            
        }else {
            hideAllButtons()
        }
        
    }
    @IBAction func onPressSpeed(_ sender: Any) {
        if speedSizeView.isHidden {
        fontSizeView.hide()
        recordSizeView.hide()
            speedSizeView.unhide()
            
        }else {
            hideAllButtons()
        }
        
    }
    @IBAction func onPressSize(_ sender: Any) {
        if recordSizeView.isHidden {
        fontSizeView.hide()
        recordSizeView.unhide()
            speedSizeView.hide()
            
        }else {
            hideAllButtons()
        }
        
    }
    @IBAction func onPressOnBackground(_ sender: Any) {
       hideAllButtons()
        
    }
    
    
    
    
    //Font
    @IBAction func onFontSizeChange(_ sender: UISlider) {
        delegate?.didChangeFontSize(newValue: sender.value)
       
    }
    
    //Speed
    @IBAction func onChangeSpeed(_ sender: UISlider) {
        delegate?.didChangeSpeed(newValue: sender.value)
        fontSizeLabel.text = Int(Float(sender.value.description)! * 100 ).description
    }
    
    @IBAction func onPressTest(_ sender: UIButton) {
        isTesing.toggle()
        if isTesing {
            delegate?.onPressTest()
        sender.setTitle("Stop", for: .normal)
        }else {
            delegate?.onPressStopTest()
            sender.setTitle("Test", for: .normal)
        }
    }
    
    
    //Recored Video Size
    
    @IBAction func onPressSquare(_ sender: UIButton) {
        delegate?.didChangeRecoredSize(recoredSize: .square)
        hideAllButtons()
        
    }
    
    
    @IBAction func onPressPost(_ sender: UIButton) {
        delegate?.didChangeRecoredSize(recoredSize: .post)
        hideAllButtons()
        
    }
    
    
    @IBAction func onPressStory(_ sender: UIButton) {
        delegate?.didChangeRecoredSize(recoredSize: .story)
        hideAllButtons()
        
    }
    
    
    func changeLabelText(_ text : String){
        fontSizeLabel.text = text
    }
    
    
    
    func hideAllButtons(){
        fontSizeView.hide()
        recordSizeView.hide()
        speedSizeView.hide()
       
    }
    
    
    func hideAllControlButtons(){
        self.videoRecordSizeButton.hide()
        self.changeTextSizeButton.hide()
        self.changeSpeedButton.hide()
    }
    func presentAllControlButtons(){
        self.videoRecordSizeButton.unhide()
        self.changeTextSizeButton.unhide()
        self.changeSpeedButton.unhide()
    }
    func presentButtonsForLandscapeMode(){
        hideAllButtons()
        videoRecordSizeButton.hide()
    }
    
    func presentButtonsForPortraitMode(){
        hideAllButtons()
        videoRecordSizeButton.unhide()
    }
    
    
    
    
    
   
   
    
    
    
    
}

extension UIView {
    func hide(){
        self.isHidden = true
    }
    
    func unhide(){
        self.isHidden = false
    }
}
