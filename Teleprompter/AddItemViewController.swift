//
//  AddItemViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit

enum AddItemError : String ,  LocalizedError {
    case fillData = "Please Fill Data"
    case titleTextNotEnough = "add at least 5 characters for script title "
    case textScriptNotEnough = "add at least 100 characters for script content"
    
    var errorDescription: String? {
        return self.rawValue
    }
}

class AddItemViewController : UIViewController {
    weak var delegate : AddItemViewControllerDelegate?
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var titleWordsCount: UILabel!
    @IBOutlet weak var detailsTextView: UITextView!
    @IBOutlet var bottomConstraints: UIView!
    private var wordsCount : Int = 0
    private let maxCount : Int = 20
    
    var scriptItem : ScriptItem? = nil
    
    private let cache = ScriptsCache.shared
    
    @IBAction private func didChangedText(_ sender: UITextField) {
        updateTitleCount(getTitle())
        setTitleTextCount()
    }
    @IBAction private func onPressSave(_ sender: Any) {
        do {
        if let scriptItem = scriptItem {
                try updateScriptItem(scriptItem: scriptItem)
            

        }else {
            saveScriptItem()
            
        }
        }
        catch {
            presentErrorMessage(content: error.localizedDescription)
        }
            
        }
        
    func saveScriptItem(){
        do {
            let scriptItem = try createScriptItem()
            try cache.addScriptItem(scriptItem)
            delegate?.updateList()
            dismiss(animated: true, completion: nil)
            }
        
        catch{
            presentErrorMessage(content: error.localizedDescription)
        }
    }
    func updateScriptItem(scriptItem : ScriptItem) throws{
        guard wordsCount  >= 1 , let detailsText = detailsTextView.text , detailsText.wordsCount >= 1 else {
            throw AddItemError.fillData
        }
        try cache.updateScriptItem(title: getTitle(), content: detailsText, id: scriptItem.id)
        dismiss(animated: true, completion: nil)
        delegate?.updateList()
    }
    
    
    @IBAction private func onPressCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTextFieldTitle()
        
        loadScriptItemToView()
    
        
    }
    
    private func createScriptItem()throws->ScriptItem {
        guard wordsCount  >= 1 , let detailsText = detailsTextView.text , detailsText.wordsCount >= 1 else {
            throw AddItemError.fillData
        }
        guard detailsText.count >= 100 else {throw AddItemError.textScriptNotEnough}
        guard getTitle().count >= 5 else {throw AddItemError.titleTextNotEnough}
        let scriptItem = ScriptItem(scriptTitle: getTitle(), scriptContent: detailsText, lastUpdateDateTime: Date(), createdDateTime: Date(), id: UUID.init().uuidString)
        return scriptItem
    }
    
    private func configTextFieldTitle(){
        titleTextField.delegate  = self
    }
    
    private func setTitleTextCount(){
        let count = "\(wordsCount) / \(maxCount)"
        titleWordsCount.text = count
    }
   private  func isTitleLimitExceeded()->Bool{
        self.wordsCount >= maxCount
    }
    
    private func updateTitleCount(_ text : String){
        self.wordsCount = text.wordsCount
       
    }
    private func getTitle()->String{
        titleTextField.text ?? ""
    }
    
    private func loadScriptItemToView(){
        if let scriptItem = scriptItem {
        self.detailsTextView.text = scriptItem.scriptContent
        self.titleTextField.text = scriptItem.scriptTitle
        self.scriptItem = scriptItem
        updateTitleCount(scriptItem.scriptTitle)
        setTitleTextCount()
            
        }
    }
    
     
}
extension AddItemViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            return true
        }else {
          return !isTitleLimitExceeded()
            
        }
    }
}

extension String {
    var wordsCount : Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = self.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        return words.count
    }
}

extension UIViewController {
    func presentErrorMessage(title : String = "Error" , content : String) {
        self.view.endEditing(true)//Dismiss Keyboard
        let alertViewController = UIAlertController(title: title, message: content, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {_ in alertViewController.dismiss(animated: true , completion: nil)}))
        present(alertViewController, animated: true, completion: nil)
    }
}
