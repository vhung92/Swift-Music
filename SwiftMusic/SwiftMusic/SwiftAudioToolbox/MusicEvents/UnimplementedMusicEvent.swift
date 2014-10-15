//
//  UnimplementedMIDIEvent.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/2/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation
import AudioToolbox

public class UnimplementedMusicEvent: MusicEvent, Printable {
    init(timestamp:MusicTimeStamp) {
        super.init(timestamp: Float(timestamp))
    }
    
    public override var description: String {
        return "UnimplementedMusicEvent{timestamp:\(timestamp)}"
    }
}