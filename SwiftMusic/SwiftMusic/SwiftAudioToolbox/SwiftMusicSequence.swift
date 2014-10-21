//
//  MusicSequence.swift
//  SwiftAudioToolbox
//
//  Created by Daniel Schlaug on 9/29/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation
import AudioToolbox

public class SwiftMusicSequence {
    let cMusicSequence: MusicSequence
    
    public var trackCount: Int {
        get {
            var trackCount:UInt32 = 0
            MusicSequenceGetTrackCount(cMusicSequence, &trackCount)
            return Int(trackCount)
        }
    }
    
    internal init(cMusicSequence: MusicSequence) {
        self.cMusicSequence = cMusicSequence
    }
    
    public init() {
        cMusicSequence = MusicSequence()
        NewMusicSequence(&cMusicSequence)
    }
    
    public convenience init(midiData:NSData) {
        //Initialize the underlying sequence
        self.init()
        
        //Load the data contents
        MusicSequenceFileLoadData(cMusicSequence, midiData, MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType), MusicSequenceLoadFlags(kMusicSequenceLoadSMF_ChannelsToTracks))
    }
    
    public func trackWithIndex(index:Int) -> SwiftMusicTrack {
        assert(0 <= index && index <= self.trackCount, "SwiftMusicSequence track index out of bounds: \(index)")
        var cMusicTrack: MusicTrack = MusicTrack()
        MusicSequenceGetIndTrack(cMusicSequence, UInt32(index), &cMusicTrack)
        return SwiftMusicTrack(cMusicTrack: cMusicTrack, musicSequence: self)
    }
    
    public func newTrack() -> SwiftMusicTrack {
        var cMusicTrack: MusicTrack = MusicTrack()
        MusicSequenceNewTrack(cMusicSequence, &cMusicTrack)
        return SwiftMusicTrack(cMusicTrack: cMusicTrack, musicSequence: self)
    }
    
    public func writeToMIDIFile(fileURL:NSURL) {
        MusicSequenceFileCreate(self.cMusicSequence, fileURL, MusicSequenceFileTypeID(kMusicSequenceFile_MIDIType), MusicSequenceFileFlags(kMusicSequenceFileFlags_EraseFile), 0)
    }
    
    deinit {
        var tracks:UInt32 = 0
        MusicSequenceGetTrackCount(cMusicSequence, &tracks)
        
        for i in 0..<tracks {
            var cMusicTrack = MusicTrack()
            MusicSequenceGetIndTrack(cMusicSequence, i, &cMusicTrack)
            MusicSequenceDisposeTrack(cMusicSequence, cMusicTrack)
        }
        
        DisposeMusicSequence(cMusicSequence)
    }
}