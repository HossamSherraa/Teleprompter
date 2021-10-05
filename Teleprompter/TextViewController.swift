//
//  TextViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit
//Target :- VC.setSpeed(precentage : %) // using thie precentage you will I want to change speed of adding offset
class TextViewController : UIViewController {
    
    @IBOutlet private weak var textView: UITextView!
    private (set) var isMoving : Bool = false
    
    private let maxSpeedPerFrame  : Float = 6
    private var precentage : Float  = 0.5
    
    
    private let maxFontSize : CGFloat  = 50
    
    
    private var lastContentOffset : CGFloat = 0
    
    private var displayLink : CADisplayLink?

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configTexInsets()
        reset()
        buildDisplayLink()
        self.textView.contentOffset.y = lastContentOffset
    }
    
  
    
    @objc private func onDisplayUpdate(){
        
        if isMoving {
           let speed = getSpeed()
            let yPositionRatio = CGFloat(speed)
            addTextViewContentOffset(yValue: yPositionRatio)
        }
    }
    
    func reset(){
        self.textView.contentOffset.y = -view.frame.height / 2
        lastContentOffset = self.textView.contentOffset.y
    }
    
    func setSpeedPrecentage(_ precentage : Float){
        self.precentage = precentage
    }
    
    func setText(text : String) {
        self.textView.text = text
    }
    
    func setTextSize(size : CGFloat){
        self.textView.font = UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    func startMoving(){
        self.isMoving = true 
    }
    
    func stopMoving(){
        self.isMoving = false
    }
    
    func isTextMoving()->Bool{
        self.isMoving
    }
    
    
   private func addTextViewContentOffset(yValue : CGFloat ){
       UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction]) { [weak self] in
           guard let self = self else {return}
           self.textView.contentOffset.y += yValue
           self.lastContentOffset = self.textView.contentOffset.y
       }
    }
    
    private func configTexInsets(){
         self.textView.contentInset.top = view.frame.height / 2
         self.textView.contentInset.bottom = view.frame.height / 2
     }
     
     private func buildDisplayLink(){
         
         self.displayLink?.invalidate()
         self.displayLink = CADisplayLink(target: self, selector: #selector(onDisplayUpdate))
         displayLink?.preferredFramesPerSecond = 7
         displayLink?.add(to: RunLoop.main, forMode: .default)
     }
    
   
    private func getSpeed()->Float{
        return maxSpeedPerFrame * precentage
    }
    
    
    
    

    
}
