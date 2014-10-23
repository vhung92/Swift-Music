//
//  MIDIGenerator.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/21/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation

class MIDIGenerator {
    private var prefix:[MIDINote] = []
    var generating:Bool = false {
        didSet {
            if oldValue != generating && generating == true {
                startGeneratingTimedNotes()
            }
        }
    }
    var receptor:(MIDINote) -> Void
    var secondsPerDurationUnit = 1
    
    private let maxDurations = 128
    private let nGram:NGramModel
    private let durationMap:DurationMapper
    
    init(maxN:Int, midiReceptor: (MIDINote) -> Void) {
        nGram = NGramModel(n: maxN)
        durationMap = DurationMapper(maxMappings: UInt64(maxDurations))
        self.receptor = midiReceptor
    }
    
    func extendPrefixWith(notes:[MIDINote]) {
        self.prefix += notes
        let maxLength = nGram.n - 1
        let charactersTooMany = prefix.count - maxLength
        if charactersTooMany > 0 {
            prefix.removeRange(0..<charactersTooMany)
        }
    }
    
    func trainWith(musicSequence:SwiftMusicSequence, var consideringTracks tracks:[Int]) {
        let trackCount = musicSequence.trackCount
        sort(&tracks)
        for i in tracks {
            if i < trackCount {
                let track = musicSequence.trackWithIndex(i)
                let notes = track.notes
                let tokens = map(notes) { self.toAbsoluteToken($0, includeDuration: true) }
                nGram.train(tokens)
            } else {
                break
            }
        }
    }
    
    func toAbsoluteToken(midiNote:MIDINote, includeDuration:Bool) -> Token {
        var durationBits:UInt32 = 0
        if includeDuration {
            durationBits = durationMap.toInt(midiNote.duration)
            durationBits = durationBits << 8
        }
        let combinedBits = durationBits | UInt32(midiNote.note)
        let content:Int = Int(combinedBits)
        let token = Token(content: content)
        return token
    }
    
    func fromAbsoluteToken(token:Token, timestamp:Float) -> MIDINote {
        var durationBits = 0x0000FF00 & UInt32(token.content)
        durationBits = durationBits >> 8
        let duration = durationMap.toFloat(durationBits)
        let note = UInt8(0x000000FF & UInt32(token.content))
        return MIDINote(timestamp: timestamp, note: note, duration: duration!)
    }
    
    func startGeneratingTimedNotes() {
        if generating {
            let tokenPrefix = prefix.map { self.toAbsoluteToken($0, includeDuration: true) }
            let tokenResult = nGram.generateNextFromPrefix(tokenPrefix)
            let note = fromAbsoluteToken(tokenResult, timestamp: 0)
            
            self.extendPrefixWith([note])
            
            let timeTilNextNote = note.duration
            let timeTilNextNoteInNanos = Int64(Float64(timeTilNextNote) * Float64(secondsPerDurationUnit) * Float64(NSEC_PER_SEC))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeTilNextNoteInNanos), dispatch_get_main_queue()) {
                self.startGeneratingTimedNotes()
            }
            
            self.receptor(note)
            println(note)
        }
    }
}