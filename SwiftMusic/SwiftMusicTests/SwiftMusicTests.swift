//
//  SwiftMusicTests.swift
//  SwiftMusicTests
//
//  Created by Daniel Schlaug on 10/2/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import UIKit
import XCTest

class SwiftMusicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDurationMapper() {
        let mapper = DurationMapper(maxMappings: 4)
        let max = mapper.maxMappings
        XCTAssertEqual(mapper.toInt(1.0), UInt32(0))
        XCTAssertEqual(mapper.toInt(3.0), UInt32(1))
        XCTAssertEqual(mapper.toInt(4.0), UInt32(2))
        XCTAssertEqual(mapper.toInt(4.0), UInt32(2))
        XCTAssertEqual(mapper.toInt(1.0), UInt32(0))
        XCTAssertEqual(mapper.toInt(5.0), UInt32(3))
        XCTAssertEqual(mapper.toInt(5.5), UInt32(3))
        XCTAssertEqual(mapper.toInt(2.5), UInt32(1))
        XCTAssertEqual(mapper.toFloat(2)!, Float32(4.0))
    }
    
    func testMIDIGenerator() {
        let relativeGenerator = MIDIGenerator(maxN: 5, relativePitch: true, embedDuration: true)
        let absoluteGenerator = MIDIGenerator(maxN: 5, relativePitch: false, embedDuration: true)
        let testNotes = [
            MIDINote(timestamp: 0, note: 60, duration: 4.0),
            MIDINote(timestamp: 0, note: 61, duration: 2.0),
            MIDINote(timestamp: 0, note: 62, duration: 3.0),
            MIDINote(timestamp: 0, note: 63, duration: 5.0)
        ]
        
        for expected in testNotes {
            var actual = absoluteGenerator.fromAbsoluteToken(absoluteGenerator.toAbsoluteToken(expected), timestamp: 0)
            XCTAssertEqual(actual, expected, "Failed on notes: \(actual.description) != \(expected.description)")
        }
        
        relativeGenerator.startingPitch = 60
        var relativeTokens = relativeGenerator.toRelativeTokens(SequenceOf<MIDINote>(testNotes))
        for (token, expected) in Zip2(relativeTokens, suffix(testNotes, 3)) {
            var actual = relativeGenerator.fromRelativeToken(token, timestamp: 0)
            XCTAssertEqual(actual, expected, "Failed on notes: \(actual.description) != \(expected.description)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
