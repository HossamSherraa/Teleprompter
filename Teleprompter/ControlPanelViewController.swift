//
//  ControlPanelViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit
enum RecoredSize {
    case post , story , square
}
protocol ControlPanelDelegate : AnyObject {
    func didChangeFontSize(newValue : Float)
    func didChangeRecoredSize(recoredSize:RecoredSize)
    func didChangeSpeed(newValue : Float)
    func onPressTest()
    func onPressRecored()
    func onPressStopRecored()
}
class ControlPanelViewController : UIViewController {
    @IBOutlet weak var fontSizeView: UIView!
    @IBOutlet weak var recordSizeView: UIStackView!
    @IBOutlet weak var speedSizeView: UIView!
    
    @IBOutlet weak var fontSizeLabel: UILabel!
    
    
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
            sender.setImage(UIImage(named: "telep_video_stop"), for: .normal)
        }
        
    }
    @IBAction func onPressText(_ sender: Any) {
        
        fontSizeView.unhide()
        recordSizeView.hide()
        speedSizeView.hide()
        
    }
    @IBAction func onPressSpeed(_ sender: Any) {
        
        fontSizeView.hide()
        recordSizeView.hide()
        speedSizeView.unhide()
        
    }
    @IBAction func onPressSize(_ sender: Any) {
       
        fontSizeView.hide()
        recordSizeView.unhide()
        speedSizeView.hide()
        
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
        delegate?.onPressTest()
        isTesing.toggle()
        if isTesing {
        sender.setTitle("Stop", for: .normal)
        }else {
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
    
    //PRIVATE
    
    func hideAllButtons(){
        fontSizeView.hide()
        recordSizeView.hide()
        speedSizeView.hide()
       
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
