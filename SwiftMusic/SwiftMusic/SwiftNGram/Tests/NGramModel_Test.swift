//
//  NGramModelTest.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/16/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import XCTest

class NGramModelTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWithShortString() {
        // This is an example of a functional test case.
        let model = NGramModel(n: 7)
        let tokens = Token.arrayFromString("hellothere")
        XCTAssertEqual(tokens.count, 10)
        model.train(tokens)
        
        let l = Token.arrayFromString("l")
        XCTAssertEqual(model.frequencyOf(l), Frequency(2))
        XCTAssertEqual(l.count, 1)
        XCTAssertEqual(model.frequencyOf(Token.arrayFromString("y")), Frequency(0))
        XCTAssertEqual(model.frequencyOf(Token.arrayFromString("t")), Frequency(1))
        XCTAssertEqual(model.frequencyOf(Token.arrayFromString("h")), Frequency(2))
        XCTAssertEqual(model.frequencyOf(Token.arrayFromString("e")), Frequency(3))
        let he = Token.arrayFromString("he")
        XCTAssertEqual(he.count, 2)
        XCTAssertEqual(model.frequencyOf(he), Frequency(2))
        let hel = Token.arrayFromString("hel")
        XCTAssertEqual(hel.count, 3)
        XCTAssertEqual(model.frequencyOf(hel), Frequency(1))
        let hellothere = tokens
        XCTAssertEqual(model.frequencyOf(tokens), Frequency(0))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}

extension Token {
    static func fromChar(char:Character) -> Token {
        let characterString = String(char)
        let scalars = characterString.unicodeScalars
        
        let intValue:UInt32 = scalars[scalars.startIndex].value
        let token = Token(content: Int(intValue))
        
        return token
    }
    
    static func arrayFromString(string:String) -> [Token] {
        let corpus = string.unicodeScalars
        let tokens = map(corpus) { Token(content: Int($0.value)) }
        return tokens
    }
}