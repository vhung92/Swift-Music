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
        let tokens = SequenceOf<Character>("hellothere")
        let model = NGramModel<Character>(n: 7)
        model.train(SequenceOf<Character>(tokens))
        
        XCTAssertEqual(model.countUniqueGramsOfN(1), 6)
        XCTAssertEqual(model.countUniqueGramsOfN(2), 8)
        XCTAssertEqual(model.countUniqueGramsOfN(7), 4)
        
        let l = SequenceOf<Character>("l")
        XCTAssertEqual(model.frequencyOf(l), Frequency(2))
        XCTAssertEqual(model.frequencyOf(SequenceOf<Character>("y")), Frequency(0))
        XCTAssertEqual(model.frequencyOf(SequenceOf<Character>("t")), Frequency(1))
        XCTAssertEqual(model.frequencyOf(SequenceOf<Character>("h")), Frequency(2))
        XCTAssertEqual(model.frequencyOf(SequenceOf<Character>("e")), Frequency(3))
        let he = SequenceOf<Character>("he")
        XCTAssertEqual(model.frequencyOf(he), Frequency(2))
        let th = SequenceOf<Character>("th")
        XCTAssertEqual(model.frequencyOf(th), Frequency(1))
        let hel = SequenceOf<Character>("hel")
        XCTAssertEqual(model.frequencyOf(hel), Frequency(1))
        let helloth = SequenceOf<Character>("helloth")
        XCTAssertEqual(model.frequencyOf(helloth), Frequency(1))
        let hellothere = tokens
        XCTAssertEqual(model.frequencyOf(tokens), Frequency(0))
    }
    
    func testGeneration() {
        let model = NGramModel<Character>(n: 3)
        let corpus = " hello there fancy seeing you here, what takes you to town "
        let tokens = SequenceOf<Character>(" hello there fancy seeing you here, what takes you to town ")
        model.train(tokens)
        
        let longGeneration = model.generate(10000, fromStart: [])
        XCTAssertEqual(longGeneration.count, 10000)
        let longGenerationString = String(longGeneration)
        let endOfCorpus = suffix(corpus, 5)
        XCTAssert(longGenerationString.rangeOfString(endOfCorpus) != nil, "Generation did not generate \"\(endOfCorpus)\" in 10000 characters. (Highly unlikely).")
        let impossibleCombo = "ww"
        XCTAssert(longGenerationString.rangeOfString(impossibleCombo) == nil, "\(impossibleCombo) should never be generated but was: \(longGenerationString)")
        
        let fa = SequenceOf<Character>("fa")
        XCTAssertEqual(model.generateNextFromPrefix(fa), Character("n"))
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}