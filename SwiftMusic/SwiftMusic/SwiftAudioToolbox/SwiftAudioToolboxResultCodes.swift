//
//  SwiftAudioToolboxResultCodes.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 9/29/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation

enum AudioToolboxResult: Int {
    case InvalidSequenceType = -10846
    case TrackIndexError = -10859
    case TrackNotFound = -10858
    case EndOfTrack = -10857
    case StartOfTrack = -10856
    case IllegalTrackDestination = -10855
    case NoSequence = -10854
    case InvalidEventType = -10853
    case InvalidPlayerState = -10852
    case CannotDoInCurrentContext = -10863
}