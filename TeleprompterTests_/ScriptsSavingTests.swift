//
//  ScriptsSavingTests.swift
//  TeleprompterTests_
//
//  Created by Hossam on 05/10/2021.
//

import Foundation
import XCTest

@testable import  Teleprompter
class ScriptsSavingTests: XCTestCase {

   let id = "1m2m3m"
    let coder = ScriptsCache.shared

    func testSaving() throws {
        let scriptItem = ScriptItem(scriptTitle: "That's a Title", scriptContent: "TTT Content", lastUpdateDateTime: Date(), createdDateTime: Date(), id: id)
        try coder.addScriptItem(scriptItem)
    }
    
    func testGet() throws {
        XCTAssertNoThrow( try coder.getScriptsHeader(scriptItemid: id))
        XCTAssertNoThrow(try coder.getScriptItem(id: id))
        XCTAssert( !coder.getScriptsListKeys().isEmpty)
    }
    
    

    
    func testUpdate() throws {
        let oldScriptItem = try coder.getScriptItem(id: id)
        let updated = ScriptItem.init(scriptTitle: "NewTitle", scriptContent:"NewContent", lastUpdateDateTime: Date(), createdDateTime: oldScriptItem.createdDateTime, id: oldScriptItem.id)
        
        coder.removeScriptItem(id: oldScriptItem.id)
        try coder.addScriptItem(updated)
        
        print(try coder.getScriptItem(id: id))
        
    }
    
    func testRemove() throws {
        coder.removeScriptItem(id: id)
        XCTAssertThrowsError(try coder.getScriptItem(id: id))
    }
    

}
