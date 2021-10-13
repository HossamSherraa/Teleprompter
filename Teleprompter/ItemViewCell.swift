//
//  ItemViewCell.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit
protocol ItemViewCellDelegate : AnyObject {
    func onPressMenu(at indexPath : IndexPath)
}
class ItemViewCell : UITableViewCell {
   private  weak var delegate : ItemViewCellDelegate?
    private var indexPath : IndexPath!
    @IBOutlet private weak var itemTitle: UILabel!
    @IBAction private func onPressMenu(_ sender: UIButton) {
        delegate?.onPressMenu(at: indexPath)
    }
    
    public func setIndexPath(_ indexPath : IndexPath){
        self.indexPath = indexPath
    }
    
    public func setCellActionsDelegate(_ delegate : ItemViewCellDelegate){
        self.delegate = delegate
    }
    
    public func setTitle(text : String){
        self.itemTitle.text = text
    }
    
    
}
