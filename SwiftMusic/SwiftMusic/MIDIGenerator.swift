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
    var receptor:(MIDINote, secondsPerDurationUnit:Double) -> Void = { println("No receptor configured for note event: \($0)") }
    var secondsPerDurationUnit = 0.7
    var startingPitch:UInt8 = 60
    var defaultDuration:Float32 = 0.5
    var embedDuration = false
    var generateDurations = true
    
    private let maxDurations = 128
    private let relativeZeroOffset = 127
    
    private let melodyNGram:NGramModel
    private let durationNGram:NGramModel
    private let durationMap:DurationMapper
    private let relativePitch:Bool
    
    init(maxN:Int, relativePitch:Bool = true) {
        melodyNGram = NGramModel(n: maxN)
        durationNGram = NGramModel(n: maxN)
        durationMap = DurationMapper(maxMappings: UInt64(maxDurations))
        self.relativePitch = relativePitch
    }
    
    func extendPrefixWith(notes:[MIDINote]) {
        self.prefix += notes
        let maxLength = melodyNGram.n - 1
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
                var tokens:SequenceOf<Token>
                if self.relativePitch {
                    tokens = SequenceOf<Token>(toRelativeTokens(notes, embedDuration: embedDuration))
                } else {
                    tokens = SequenceOf<Token>(map(notes) { self.toAbsoluteToken($0, includeDuration: self.embedDuration) })
                }
                melodyNGram.train(tokens)
            } else {
                break
            }
        }
    }
    
    func toRelativeTokens(notes:SequenceOf<MIDINote>, embedDuration:Bool) -> SequenceOf<Token> {
        return SequenceOf<Token> { () -> GeneratorOf<Token> in
            var noteGenerator = notes.generate()
            var previousNote = noteGenerator.next()
            return GeneratorOf<Token> { () -> Token? in
                var relativeToken:Token? = nil
                
                if let currentNote = noteGenerator.next() {
                    let pitchChange = Int(Int(currentNote.note) - Int(previousNote!.note))
                    let relativeNote = MIDINote(
                        timestamp:          currentNote.timestamp,
                        note:               UInt8(pitchChange + self.relativeZeroOffset),
                        duration:           currentNote.duration,
                        velocity:           currentNote.velocity,
                        releaseVelocity:    currentNote.velocity,
                        channel:            currentNote.channel
                    )
                    
                    relativeToken = self.toAbsoluteToken(relativeNote, includeDuration: embedDuration)
                    previousNote = currentNote
                }
                return relativeToken
            }
        }
    }
    
    func fromRelativeToken(token:Token, timestamp:Float) -> MIDINote {
        var relativeNote = fromAbsoluteToken(token, timestamp: timestamp)
        
        var absolutePitch = Int(relativeNote.note) - relativeZeroOffset + Int(startingPitch)
        assert(absolutePitch <= 127 && absolutePitch >= 0, "Relative pitch out of bounds: \(absolutePitch)")
        startingPitch = UInt8(absolutePitch)
        return MIDINote(
            timestamp:          relativeNote.timestamp,
            note:               startingPitch,
            duration:           relativeNote.duration,
            velocity:           relativeNote.velocity,
            releaseVelocity:    relativeNote.releaseVelocity,
            channel:            relativeNote.channel
        )
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
        var duration = durationMap.toFloat(durationBits)
        if duration == nil {duration = defaultDuration}
        let note = UInt8(0x000000FF & UInt32(token.content))
        return MIDINote(timestamp: timestamp, note: note, duration: duration!)
    }
    
    func startGeneratingTimedNotes() {
        if generating {
            let tokenPrefix = prefix.map { self.toAbsoluteToken($0, includeDuration: true) }
            let tokenResult = melodyNGram.generateNextFromPrefix(tokenPrefix)
            var note:MIDINote
            if self.relativePitch {
                note = fromRelativeToken(tokenResult, timestamp: 0)
            } else {
                note = fromAbsoluteToken(tokenResult, timestamp: 0)
            }
            
            self.extendPrefixWith([note])
            
            let timeTilNextNote = note.duration
            let timeTilNextNoteInNanos = Int64(Float64(timeTilNextNote) * Float64(secondsPerDurationUnit) * Float64(NSEC_PER_SEC))
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, timeTilNextNoteInNanos), dispatch_get_main_queue()) {
                self.startGeneratingTimedNotes()
            }
            
            self.receptor(note, secondsPerDurationUnit:secondsPerDurationUnit)
            println(note)
        }
    }
}