//
//  SwiftMusicSequenceTest.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 10/1/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import UIKit
import XCTest

class SwiftMusicSequenceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBasicFunctionality() {
        // This is an example of a functional test case.
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("test", ofType:"mid")
        let testMidi = NSData(contentsOfFile: path!)
        let musicSequence = SwiftMusicSequence(midiData: testMidi!)
        XCTAssertEqual(musicSequence.trackCount, 13)
        let musicTrack = musicSequence.trackWithIndex(3)
        var nEvents = 0
        for event in musicTrack.events {
            if let event = event as? MIDINote {
                nEvents++
                XCTAssertNotEqual(event.note, UInt8(0))
                NSLog("\(event.description)")
            }
        }
        
        XCTAssertNotEqual(musicTrack.trackLength, Float(0))
        XCTAssertNotEqual(nEvents, 0)
    }
    
    func testWriteToMIDIFile() {
        let fileManager = NSFileManager.defaultManager()
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("test", ofType:"mid")
        let testMidi = NSData(contentsOfFile: path!)
        let musicSequence = SwiftMusicSequence(midiData: testMidi!)
        XCTAssertEqual(musicSequence.trackCount, 13)
        
        let destinationPath = NSURL(fileURLWithPath: "/tmp/test.mid")
        musicSequence.writeToMIDIFile(destinationPath!)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
