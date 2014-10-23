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
        let th = Token.arrayFromString("th")
        XCTAssertEqual(model.frequencyOf(th), Frequency(1))
        let hel = Token.arrayFromString("hel")
        XCTAssertEqual(hel.count, 3)
        XCTAssertEqual(model.frequencyOf(hel), Frequency(1))
        let helloth = Token.arrayFromString("helloth")
        XCTAssertEqual(model.frequencyOf(helloth), Frequency(1))
        let hellothere = tokens
        XCTAssertEqual(model.frequencyOf(tokens), Frequency(0))
    }
    
    func testGeneration() {
        let model = NGramModel(n: 3)
        let corpus = " hello there fancy seeing you here, what takes you to town "
        let tokens = Token.arrayFromString(" hello there fancy seeing you here, what takes you to town ")
        model.train(tokens)
        
        let longGeneration = model.generate(10000, fromStart: [])
        XCTAssertEqual(longGeneration.count, 10000)
        let longGenerationString = Token.arrayToString(longGeneration)
        let endOfCorpus = suffix(corpus, 5)
        XCTAssert(longGenerationString.rangeOfString(endOfCorpus) != nil, "Generation did not generate \"\(endOfCorpus)\" in 10000 characters. (Highly unlikely).")
        let impossibleCombo = "ww"
        XCTAssert(longGenerationString.rangeOfString(impossibleCombo) == nil, "\(impossibleCombo) should never be generated but was: \(longGenerationString)")
        
        let fa = Token.arrayFromString("fa")
        let n = Token.fromChar("n")
        XCTAssertEqual(model.generateNextFromPrefix(fa), n)
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
    
    static func arrayToString(array:[Token]) -> String {
        let scalars = map(array) { Character(UnicodeScalar($0.content)) }
        return String(scalars)
    }
}