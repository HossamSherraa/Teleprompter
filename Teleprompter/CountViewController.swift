//
//  CountViewController.swift
//  Teleprompter
//
//  Created by Hossam on 13/10/2021.
//

import Foundation
import UIKit
protocol CountViewControllerDelegate :AnyObject{
    func countViewControllerDidFinishCounting()
}
class CountViewController : UIViewController {
    private var value : Int = 1 {
        didSet {
            countLabelView.text = value.description
        }
    }
    weak var delegate : CountViewControllerDelegate?
    @IBOutlet weak var countLabelView: UILabel!
    
    func start(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self ] timer in
            guard let self = self else {return}
            self.value += 1
            if self.value == 4 {
                timer.invalidate()
                self.delegate?.countViewControllerDidFinishCounting()
                self.value = 1
            }
        }
    }
    
    
    
}
