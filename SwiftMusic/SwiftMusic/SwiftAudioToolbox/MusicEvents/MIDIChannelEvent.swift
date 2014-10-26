//
//  MIDIChannelEvent.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/26/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation
import AudioToolbox

enum MIDIChannelEventType {
    case ProgramChange(UInt8)
//    case PitchBend(UInt8, UInt8)  // TODO convert coarse & fine value combination to one value spanning both.
//    case ControlChange(controller:UInt8, value:UInt8)  // TODO better parameter names
    case Unimplemented
    
    init(statusByte:UInt8, dataByte1:UInt8, dataByte2:UInt8) {
        let typeBits = statusByte >> 4
        switch typeBits {
        case 0xC:
            self = .ProgramChange(dataByte1)
        default:
            self = .Unimplemented
        }
    }
}

class MIDIChannelEvent: MusicEvent {
    let type:MIDIChannelEventType
    let channel:UInt8
    init(timestamp:MusicTimeStamp, cMIDIChannelMessage:MIDIChannelMessage) {
        type = MIDIChannelEventType(statusByte: cMIDIChannelMessage.status, dataByte1: cMIDIChannelMessage.data1, dataByte2: cMIDIChannelMessage.data2)
        channel = 0b00001111 & cMIDIChannelMessage.status
        super.init(timestamp: Float(timestamp))
    }
}