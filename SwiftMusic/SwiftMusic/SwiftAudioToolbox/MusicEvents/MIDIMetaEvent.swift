//
//  MIDIMetaEvent.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 10/1/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import AudioToolbox

public typealias MicrosecondsPerQuarterNote = Int

public enum MIDIMetaEventType {
//    case SequenceNumber(Int) Probably not needed
    case Text(String)
    case CopyrightNotice(String)
    case SequenceOrTrackName(String)
    case InstrumentName(String)
    case Lyrics(String)
    case Marker(String)
    case CuePoint(String)
    case MIDIChannelPrefix(Int8)
    case EndOfTrack
    case SetTempo(MicrosecondsPerQuarterNote)
//    case SMPTEOffset
//    case TimeSignature
//    case KeySignature
//    case SequencerSpecificEvent

    init(cMetaEventType:UInt8, dataLength:UInt32, data:(UInt8)) {
        //FIXME
        self = .Text("Goj")
    }
}

public class MIDIMetaEvent:MusicEvent {
    private let _type:MIDIMetaEventType
    public var type:MIDIMetaEventType {
        return _type
    }
    
    private init(timestamp:MusicTimeStamp, cMetaEventType:UInt8, dataLength:UInt32, data:(UInt8)) {
        _type = MIDIMetaEventType(cMetaEventType: cMetaEventType, dataLength: dataLength, data: data)
        super.init(timestamp:Float(timestamp))
        
    }
}