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
    let lastUpdateDateTime : String
    let createdDateTime : String
    let id : String
}

struct ScriptItemHeader : Codable{
    let scriptTitle : String
    let lastUpdateDateTime : String
    let screatedDateTime : String
    let id : String
}

//SaveToUserDefault
struct ScriptsCache {
    let userDefaults = UserDefaults.standard
    private let scriptItemsListKey = "SCRIPTS_ID_LIST"
    /*
     It will add new Items to list
     
     1- will create ID with header ,
     2- create Header Data
     3- convertToDIC
     4- Create Item Data
     5- ConvertToDIC
     6-saveHeader
     7-SaveItem
     8-getOldListIDs
     9- appen newItemID to list
     10- saveList
     */
    func addScriptItem(_ scriptItem : ScriptItem){
        
    }
    
    func getScriptsListKeys()->[String]{
        return userDefaults.object(forKey: scriptItemsListKey) as? [String] ?? []
    }
    
    func saveScriptItemHeader(id : String){
      
    }
    
    func saveScriptItem(id:String){
        
    }
    
    func getScriptsHeader(id:String){
        
    }
    
    func getScriptItem(id:String){
        
    }
    
    func editScriptItemWith(scriptItem : ScriptItem){
        
    }
    
    func removeScriptItem(id : String){
        
    }
    
    func getHeaderID(id:String)->String{
        return id + "Header"
    }
    
    
}

struct CodableConverter{
   
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    func dictionary<T:Codable>(type : T)throws->[String:Any]{
        let data = try encoder.encode(type.self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {throw EncoderError.fail}
        return dictionary
    }
    
    func get<T:Codable>(from object : Any , to type : T) throws -> T{
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

class ItemsViewControler : UIViewController {
    @IBOutlet weak var itemsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configTableView()
    }
    
    
    func configTableView(){
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
       
    }
    
    @IBAction func onPressAddButton(_ sender: UIButton) {
        
    }
    
}


extension ItemsViewControler : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCellIdentifier")!
        return cell
    }
    
    
}



extension ItemsViewControler : UITableViewDelegate {
    
}
