//
//  MusicEvent.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 10/1/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import AudioToolbox

public class MusicEvent: Printable {
    public let timestamp:Float
    
    init(timestamp:Float) {
        self.timestamp = timestamp
    }
    
    class func eventFromData(
        timestamp:MusicTimeStamp,
        musicEventType:MusicEventType,
        eventData:UnsafePointer<Void>,
        eventDataSize:UInt32) -> MusicEvent?
    {
        switch Int(musicEventType) {
        case kMusicEventType_NULL:
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_ExtendedNote:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_ExtendedTempo:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_User:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_Meta:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_MIDINoteMessage:
            let noteMessage = UnsafePointer<MIDINoteMessage>(eventData).memory
            return MIDINote(timestamp: timestamp, cMIDINoteMessage: noteMessage)
        case kMusicEventType_MIDIChannelMessage:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_MIDIRawData:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_Parameter:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        case kMusicEventType_AUPreset:
            //TODO: Unimplemented music events
            return UnimplementedMusicEvent(timestamp:timestamp)
        default:
            return UnimplementedMusicEvent(timestamp:timestamp)
        }
    }
    
    public var description: String {
        return "MusicEvent{timestamp: \(timestamp)}"
    }
}