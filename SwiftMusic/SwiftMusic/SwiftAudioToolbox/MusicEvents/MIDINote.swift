//
//  MIDINote.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 10/1/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import AudioToolbox

public class MIDINote:MusicEvent, Printable {
    public let note:UInt8
    public let duration:Float32
    public let velocity:UInt8
    public let releaseVelocity:UInt8
    public let channel:UInt8
    
    public override var description: String {
        return "MIDINote{timestamp: \(timestamp), note: \(note), duration:\(duration), velocity:\(velocity), releaseVelocity:\(releaseVelocity)}"
    }
    
    init(timestamp:MusicTimeStamp, cMIDINoteMessage:MIDINoteMessage) {
        channel = cMIDINoteMessage.channel
        note = cMIDINoteMessage.note
        duration = cMIDINoteMessage.duration
        velocity = cMIDINoteMessage.velocity
        releaseVelocity = cMIDINoteMessage.releaseVelocity
        super.init(timestamp: Float(timestamp))
    }
    
    public init(timestamp:Float, note:UInt8, duration:Float32 = 0.5, velocity:UInt8 = 80, releaseVelocity:UInt8 = 80, channel:UInt8 = 0) {
        self.note = note
        self.duration = duration
        self.velocity = velocity
        self.releaseVelocity = releaseVelocity
        self.channel = channel
        super.init(timestamp: timestamp)
    }
    
    var cMIDINoteMessage: MIDINoteMessage {
        return MIDINoteMessage(
            channel: self.channel,
            note: self.note,
            velocity: self.velocity,
            releaseVelocity: self.releaseVelocity,
            duration: self.duration)
    }
}