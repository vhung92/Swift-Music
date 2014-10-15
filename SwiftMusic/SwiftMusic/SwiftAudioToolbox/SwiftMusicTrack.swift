//
//  SwiftMusicTrack.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 10/1/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import AudioToolbox
import Swift

public class SwiftMusicTrack {
    private let cMusicTrack:MusicTrack
    
    init(cMusicTrack:MusicTrack){
        self.cMusicTrack = cMusicTrack
    }
    
    public var events:MusicEventSequence {
        return MusicEventSequence(cMusicTrack: cMusicTrack)
    }
    
    public var trackLength:Float {
        var length = MusicTimeStamp()
        
        var dataLength:UInt32 = 0
        
        MusicTrackGetProperty(cMusicTrack, UInt32(kSequenceTrackProperty_TrackLength), &length, &dataLength)
        
        return Float(length)
    }

    public
}

public class MusicEventSequence:SequenceType {
    private let cMusicTrack:MusicTrack
    
    init(cMusicTrack:MusicTrack) {
        self.cMusicTrack = cMusicTrack
    }
    
    public func generate() -> MusicEventGenerator {
        return MusicEventGenerator(cMusicTrack: cMusicTrack)
    }
    
}

public class MusicEventGenerator:GeneratorType {
    
    let cIterator:MusicEventIterator
    
    init(cMusicTrack:MusicTrack) {
        var iterator = MusicEventIterator()
        NewMusicEventIterator(cMusicTrack, &iterator)
        cIterator = iterator
    }
    
    public func next() -> MusicEvent? {
        var timestamp:MusicTimeStamp = 0
        var eventType:MusicEventType = 0
        
        var eventData:UnsafePointer<Void> = UnsafePointer()
        var eventDataSize:UInt32 = 0
        
        var hasNext:Boolean = 0
        
        MusicEventIteratorHasNextEvent(cIterator, &hasNext)
        
        if hasNext == 1 {
            MusicEventIteratorNextEvent(cIterator)
            MusicEventIteratorGetEventInfo(cIterator, &timestamp, &eventType, &eventData, &eventDataSize)
            let event = MusicEvent.eventFromData(timestamp, musicEventType: eventType, eventData: eventData, eventDataSize: eventDataSize)
            return event
        } else {
            return nil
        }
    }
    
}