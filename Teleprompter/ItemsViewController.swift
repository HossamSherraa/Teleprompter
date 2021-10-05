//
//  ItemsViewController.swift
//  Teleprompter
//
//  Created by Hossam on 02/10/2021.
//

import UIKit

struct ScriptItem : Codable{
    let scriptTitle : String
    let scriptContent : String
    let lastUpdateDateTime : Date
    let createdDateTime : Date
    let id : String
}

struct ScriptItemHeader : Codable{
    let scriptTitle : String
    let lastUpdateDateTime : Date
    let screatedDateTime : Date
    let id : String
}

//SaveToUserDefault
class ScriptsCache {
    static let shared : ScriptsCache = .init()
    private init(){}
    enum ScriptsCacheError : Error {
        case notFound
    }
    private let userDefaults = UserDefaults.standard
    private let codableConverter : CodableConverter  = .shared
    private let scriptItemsListKey = "SCRIPTS_ID_LIST"
    public func addScriptItem(_ scriptItem : ScriptItem) throws{
        /*
         1- get header ID
         2- get scropt item ID
         3- get header
         4- getHeaderDIC
         5- get item DIC
         6- save Header (headerID : HeaderDIC)
         7- save scriptItem (ScriptItemID : ScriptItemDic)
         8- getAllListOFScripts and append new SCRIPT ID and saveIT
         */
        
        //Header
        let scriptHeaderKey = getHeaderID(id: scriptItem.id)
        let headerData = createHeaderFrom(scriptItem: scriptItem)
        let scriptHeaderDictionary = try codableConverter.dictionary(type: headerData)
        
        //Item
        let itemKey = scriptItem.id
        let scriptItemDictionary = try codableConverter.dictionary(type: scriptItem)
        
        //
        save(value: scriptHeaderDictionary, id: scriptHeaderKey)
        save(value: scriptItemDictionary, id: itemKey)
        
        //
        
        saveItemKey(id: itemKey)
        
        
        
    }
    
    
    public func getAllHeaders()->[ScriptItemHeader]{
        
        do {
            return try self.getScriptsListKeys().map({ try self.getScriptsHeader(scriptItemid: $0)}).sorted(by: {$0.lastUpdateDateTime > $1.lastUpdateDateTime})
            
        } catch {
            print(error)
            return []
        }
        
    }
    
    public func getScriptsHeader(scriptItemid:String) throws -> ScriptItemHeader{
        let headerID = getHeaderID(id: scriptItemid)
        guard let scriptItemHeaderDic = userDefaults.object(forKey: headerID) as? [String:Any] else { throw ScriptsCacheError.notFound}
        let scriptItemHeader = try codableConverter.get(from: scriptItemHeaderDic, to: ScriptItemHeader.self)
        return scriptItemHeader
    }
    
    public func getScriptItem(id:String)throws->ScriptItem{
        guard let scriptItemDic = userDefaults.object(forKey: id) as? [String:Any] else { throw ScriptsCacheError.notFound}
        let scriptItem = try codableConverter.get(from: scriptItemDic, to: ScriptItem.self)
        return scriptItem
        
    }
    
    public func getScriptsListKeys()->[String]{
        return userDefaults.object(forKey: scriptItemsListKey) as? [String] ?? []
    }
    
    public func updateScriptItem(title : String , content : String , id : String) throws{
        let oldScriptItem = try getScriptItem(id: id)
        let updatedScriptItem = ScriptItem.init(scriptTitle: title, scriptContent:content, lastUpdateDateTime: Date(), createdDateTime: oldScriptItem.createdDateTime, id: id)
        
        removeScriptItem(id: oldScriptItem.id)
        try addScriptItem(updatedScriptItem)
    }
    
    public func removeScriptItem(id : String){
        let headerID = getHeaderID(id: id)
        userDefaults.removeObject(forKey: headerID)
        userDefaults.removeObject(forKey: id)
        removeItemKey(id: id)
    }
    
    
    private func save( value : [String : Any] ,  id : String){
        userDefaults.set(value, forKey: id)
        
    }
    
    
    private  func saveListItemsKey( list:[String] ){
        userDefaults.set(list, forKey: scriptItemsListKey)
        
    }
    
    private func getHeaderID(id:String)->String{
        return id + "Header"
    }
    
    
    private func saveItemKey(id : String){
        var listItemsKey = getScriptsListKeys()
        listItemsKey.append(id)
        saveListItemsKey(list: listItemsKey)
    }
    
    private func removeItemKey(id : String){
        var listItemsKey = getScriptsListKeys()
        listItemsKey.removeAll(where: {$0 == id})
        saveListItemsKey(list: listItemsKey)
    }
    private func createHeaderFrom(scriptItem : ScriptItem)->ScriptItemHeader{
        return ScriptItemHeader.init(scriptTitle: scriptItem.scriptTitle, lastUpdateDateTime: scriptItem.lastUpdateDateTime, screatedDateTime: scriptItem.createdDateTime, id: scriptItem.id)
    }
    
    
}

struct CodableConverter{
    
    static let shared : CodableConverter = CodableConverter()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    func dictionary<T:Codable>(type : T)throws->[String:Any]{
        let data = try encoder.encode(type.self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {throw EncoderError.fail}
        return dictionary
    }
    
    func get<T:Codable>(from object : Any , to type : T.Type) throws -> T{
        let data = try JSONSerialization.data(withJSONObject: object, options: [])
        let result = try decoder.decode(T.self, from: data)
        return result
    }
    
    
    
    
    enum EncoderError : Error {
        case fail
    }
    
    enum DecoderError : Error{
        case fail
    }
}

protocol AddItemViewControllerDelegate : AnyObject {
    func updateList()
}
class ItemsViewControler : UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    let scriptsCache = ScriptsCache.shared
    private var scriptsHeaders : [ScriptItemHeader] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
        self.updateScreenWithAllScriptsList()
    }
    
    private func configTableView(){
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        
    }
    
    @IBAction func onPressAddButton(_ sender: UIButton) {
        let vc = UIViewController.instantiateViewController(using: "AddItemViewController", type: AddItemViewController.self)
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        vc.delegate = self
        self.present(vc, animated: true, completion: nil)
    }
    
    private func updateScreenWithAllScriptsList(){
        self.scriptsHeaders.removeAll()
        self.scriptsHeaders =  scriptsCache.getAllHeaders()
        itemsTableView.reloadData()
    }
    
    private  func getHeaderAt(index : Int)->ScriptItemHeader {
        self.scriptsHeaders[index]
    }
    
    private func configCell(_ itemViewCell : ItemViewCell , indexPath : IndexPath)->ItemViewCell {
        let scriptHeader = getHeaderAt(index: indexPath.row)
        itemViewCell.setIndexPath(indexPath)
        itemViewCell.setTitle(text: scriptHeader.scriptTitle)
        itemViewCell.setCellActionsDelegate(self)
        return itemViewCell
    }
    
    private func getSelectedScriptItem(indexPath : IndexPath)throws ->ScriptItem {
        let selectedHeader = getHeaderAt(index: indexPath.row)
        let scriptItem = try scriptsCache.getScriptItem(id: selectedHeader.id)
        return scriptItem
    }
    
    private func goToRecoredScreenFromItem(At indexPath : IndexPath){
        do{
            let selectedHeader = getHeaderAt(index: indexPath.row)
            let scriptItem = try scriptsCache.getScriptItem(id: selectedHeader.id)
            let recordVideoController = RecoredVideoViewController()
           recordVideoController.scriptItem = scriptItem
           self.present(recordVideoController, animated: true, completion: nil)}
        catch{
            presentErrorMessage(content: error.localizedDescription)
        }
    }
    
    
}


extension ItemsViewControler : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scriptsHeaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellIdentifier")! as! ItemViewCell
        return configCell(cell, indexPath: indexPath)
    }
    
}



extension ItemsViewControler : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToRecoredScreenFromItem(At: indexPath)
    }
}

extension ItemsViewControler : ItemViewCellDelegate {
    func onPressMenu(at indexPath: IndexPath) {
        let id = getHeaderAt(index: indexPath.row).id
        
        let alert = UIAlertController(title: "Options", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default , handler:{ [weak self](UIAlertAction)in
            if
            let scriptItem = try? self?.scriptsCache.getScriptItem(id: id){
                let vc = UIViewController.instantiateViewController(using: "AddItemViewController", type: AddItemViewController.self)
                vc.modalTransitionStyle = .crossDissolve
                vc.modalPresentationStyle = .overFullScreen
                vc.delegate = self
                vc.scriptItem = scriptItem
                self?.present(vc, animated: true, completion: nil)
            }else {
                self?.presentErrorMessage(content: "Fail To Edit")
            }
            
            
        }))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive , handler:{[weak self] (UIAlertAction)in
            
            self?.makeDicision(title: "Click Yes To Delete Selected File!") { [weak self] in
                self?.scriptsCache.removeScriptItem(id: id)
                self?.updateScreenWithAllScriptsList()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        
        let cell = self.itemsTableView.cellForRow(at: indexPath)
        alert.popoverPresentationController?.sourceRect = cell!.bounds
        alert.popoverPresentationController?.sourceView = cell!
        
        alert.modalPresentationStyle = .popover
    
        self.present(alert, animated: true)
    }
    
    
}

extension UIViewController{
    func makeDicision(title : String , onYes : @escaping ()->Void) {
        
        let alert = UIAlertController(title: "Yes", message: title, preferredStyle: UIAlertController.Style.alert)
        
        
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler: {_ in
            onYes()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
}


extension ItemsViewControler : AddItemViewControllerDelegate {
    func updateList() {
        self.updateScreenWithAllScriptsList()
    }
    
    
}
