//
//  TeleprompterTests_.swift
//  TeleprompterTests_
//
//  Created by Hossam on 05/10/2021.
//

import XCTest

@testable import  Teleprompter
class TeleprompterTests_: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let object = ScriptItem(scriptTitle: "Title", scriptContent: "Contetn", lastUpdateDateTime: Date(), createdDateTime: Date(), id: "33d")
        let result = try CodableConverter().dictionary(type: object)
        XCTAssert(result.count != 0)
        
    }
    
    func testEncode()throws{
        let dic = ["lastUpdateDateTime": "Date", "id": "33d", "scriptContent": "Contetn", "scriptTitle": "Title", "createdDateTime": "Date"]
        let secriptItem = try CodableConverter().get(from: dic, to: ScriptItem.self)
        XCTAssert(secriptItem.id == "33d")
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
