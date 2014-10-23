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
    public let musicSequence:SwiftMusicSequence
    
    init(cMusicTrack:MusicTrack, musicSequence: SwiftMusicSequence){
        self.cMusicTrack = cMusicTrack
        self.musicSequence = musicSequence
    }
    
    public var events:MusicEventSequence {
        return MusicEventSequence(cMusicTrack: cMusicTrack)
    }
    
    public var notes:SequenceOf<MIDINote> {
        return SequenceOf<MIDINote>({ () -> GeneratorOf<MIDINote> in
            let eventSequence = self.events
            let eventGenerator = eventSequence.generate()
            return GeneratorOf<MIDINote>({
                var note:MIDINote? = nil
                while note == nil {
                    if let event = eventGenerator.next() {
                        note = event as? MIDINote
                    } else {
                        return nil
                    }
                }
                return note!
            })
        })
    }
    
//    public struct MIDINoteSequence: SequenceType {
//        let eventSequence = self.events
//        func generate() -> GeneratorOf<MIDINote> {
//            var eventGenerator = eventSequence.
//        }
//    }
    
    public var trackLength:Float {
        var length = MusicTimeStamp()
        
        var dataLength:UInt32 = 0
        
        MusicTrackGetProperty(cMusicTrack, UInt32(kSequenceTrackProperty_TrackLength), &length, &dataLength)
        
        return Float(length)
    }

    public func addMusicEvent(musicEvent: MusicEvent) {
        if let midiNote = musicEvent as? MIDINote {
            let timestamp:MusicTimeStamp = Float64(midiNote.timestamp)
            var cMIDINoteMessage = midiNote.cMIDINoteMessage
            MusicTrackNewMIDINoteEvent(cMusicTrack, timestamp, &cMIDINoteMessage)
        }
    }
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