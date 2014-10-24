//
//  MIDIGenerator.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/21/14.
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
    var embedDuration = false
    var generateDurations = true
    
    var defaultDuration:Float32 = 0.5
    var defaultVelocity:UInt8 = 70
    
    private let maxDurations = 128
    private let relativeZeroOffset = 127
    
    private let melodyNGram:NGramModel<PitchAndDuration>
    private let durationNGram:NGramModel<UInt8>
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
        let maxLength = relativePitch ? melodyNGram.n : melodyNGram.n - 1
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
                var tokens:SequenceOf<PitchAndDuration>
                if self.relativePitch {
                    tokens = SequenceOf<PitchAndDuration>(toRelativeTokens(notes))
                } else {
                    tokens = SequenceOf<PitchAndDuration>(map(notes, toAbsoluteToken))
                }
                melodyNGram.train(tokens)
            } else {
                break
            }
        }
    }
    
    func toRelativeTokens(notes:SequenceOf<MIDINote>) -> SequenceOf<PitchAndDuration> {
        return SequenceOf<PitchAndDuration> { () -> GeneratorOf<PitchAndDuration> in
            var noteGenerator = notes.generate()
            var previousNote = noteGenerator.next()
            return GeneratorOf<PitchAndDuration> { () -> PitchAndDuration? in
                var relativeToken:PitchAndDuration? = nil
                
                if let currentNote = noteGenerator.next() {
                    let pitchChange = Int8(Int(currentNote.note) - Int(previousNote!.note))
                    let duration = self.embeddedDurationFrom(currentNote)
                    relativeToken = PitchAndDuration(pitch: pitchChange, duration: duration)
                    
                    previousNote = currentNote
                }
                
                return relativeToken
            }
        }
    }
    
    func fromRelativeToken(token:PitchAndDuration, timestamp:Float) -> MIDINote {
        let pitch = Int(startingPitch) + Int(token.pitch)
        startingPitch = UInt8(pitch)
        assert(pitch <= 127 && pitch >= 0, "Relatively generated pitch out of bounds: \(pitch)")
        
        var duration = durationFromEmbedded(token.duration)
        
        return MIDINote(
            timestamp:          timestamp,
            note:               UInt8(pitch),
            duration:           duration
        )
    }
    
    func toAbsoluteToken(midiNote:MIDINote) -> PitchAndDuration {
        var intDuration = embeddedDurationFrom(midiNote)
        return PitchAndDuration(pitch: Int8(midiNote.note), duration: UInt8(intDuration))
    }
    
    func embeddedDurationFrom(midiNote:MIDINote) -> UInt8 {
        return self.embedDuration ? UInt8(self.durationMap.toInt(midiNote.duration)) : UInt8.max
    }
    func durationFromEmbedded(int:UInt8) -> Float32 {
        return self.embedDuration ? durationMap.toFloat(UInt32(int))! : self.defaultDuration
    }
    
    func fromAbsoluteToken(token:PitchAndDuration, timestamp:Float) -> MIDINote {
        let duration:Float32 = durationFromEmbedded(token.duration)
        let note = UInt8(token.pitch)
        return MIDINote(timestamp: timestamp, note: note, duration: duration)
    }
    
    func startGeneratingTimedNotes() {
        if generating {
            var tokenPrefix:[PitchAndDuration]
            if self.relativePitch {
                tokenPrefix = Array(toRelativeTokens(SequenceOf<MIDINote>(prefix)))
            } else {
                tokenPrefix = prefix.map { self.toAbsoluteToken($0) }
            }
            
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