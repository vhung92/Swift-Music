//
//  PitchAndDuration.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/24/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation

struct PitchAndDuration:Hashable {
    let pitch:Int8
    let duration:UInt8
    
    var hashValue: Int {
        return Int(pitch) | Int(UInt32(duration) << 8)
    }
}

func ==(lhs: PitchAndDuration, rhs: PitchAndDuration) -> Bool {
    return lhs.pitch == rhs.pitch && lhs.duration == rhs.duration
}