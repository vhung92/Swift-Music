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
    var midiNoteRange:Range<Int> = 0...126
    var allowedNoteRange = 36...85
    var startingPitch:UInt8 = 60
    var targetPitch:UInt8? = 60
    var n:Int
    
    var defaultDuration:Float32 = 0.5
    var defaultVelocity:UInt8 = 70
    
    private let maxDurations = 128
    
    //Constant parameters
    private let relativePitch:Bool
    private let embedDuration:Bool
    private let maxN:Int
    
    private let melodyNGram:NGramModel<PitchAndDuration>
    private let durationNGram:NGramModel<UInt8>
    private let durationMap:DurationMapper
    
    init(maxN:Int, relativePitch:Bool, embedDuration:Bool) {
        self.melodyNGram = NGramModel(n: maxN)
        self.durationNGram = NGramModel(n: maxN)
        self.maxN = maxN
        self.n = maxN
        self.embedDuration = embedDuration
        self.relativePitch = relativePitch
        
        self.durationMap = DurationMapper(maxMappings: UInt64(maxDurations))
        if relativePitch {
            self.melodyNGram.filter = {
                self.wrapAround(self.weakCut(self.analyse($0, $1)))
            }
        } else {
            self.melodyNGram.filter = analyse
        }
    }
    
    func extendPrefixWith(notes:[MIDINote]) {
        self.prefix += notes
        let maxLength = relativePitch ? self.maxN : self.maxN - 1
        let charactersTooMany = prefix.count - maxLength
        if charactersTooMany > 0 {
            prefix.removeRange(0..<charactersTooMany)
        }
    }
    func clearPrefix() {
        self.prefix = []
    }
    
    private func analyse(successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
        if successorDistribution.count > 0 {
            println("\(successorDistribution.count)\t\(prefixLength)")
        }
        return (successorDistribution, prefixLength)
    }
    private func print(successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
//        println("Successors: \(successorDistribution.count)")
        println("\(successorDistribution)")
        return (successorDistribution, prefixLength)
    }
    private func wrapAround(successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
        let transformedDistribution = successorDistribution.map { (var pitchWrapper:PitchAndDuration, frequency:Frequency) -> (PitchAndDuration, Frequency) in
            var pitchChange = pitchWrapper.pitch
            let absoluteNote = { Int(self.startingPitch) + Int(pitchChange) }
            if !self.inMidiRange(absoluteNote()) {
                println("-1\t-1")
                while absoluteNote() < self.midiNoteRange.startIndex {
                    pitchChange += 12
                }
                while absoluteNote() >= self.midiNoteRange.endIndex {
                    pitchChange -= 12
                }
                pitchWrapper = PitchAndDuration(pitch: pitchChange, duration: pitchWrapper.duration)
            }
            return (pitchWrapper, frequency)
        }
        return (transformedDistribution, prefixLength)
    }
    private func pullBack(var successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
        let absoluteNote = {(relNote:Int8) -> Int in
            return Int(self.startingPitch) + Int(relNote)
        }
        successorDistribution = successorDistribution.map {
            let relativeNote = $0.0.pitch
            if (absoluteNote(0) < self.midiNoteRange.startIndex
            && relativeNote > 0)
            || (absoluteNote(0) >= self.midiNoteRange.endIndex
            && relativeNote < 0) {
                return ($0.0, $0.1*1000)
            } else {
                return $0
            }
        }
        return (successorDistribution, prefixLength)
    }
    private func weakCut(var successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
        let hugeScaler = UInt64(1000)
        let absoluteNote = {(relNote:Int8) -> Int in
            return Int(self.startingPitch) + Int(relNote)
        }
        successorDistribution = successorDistribution.map {
            if self.inAllowedRange(absoluteNote($0.0.pitch)) {
                return ($0.0, $0.1*hugeScaler)
            } else {
                return $0
            }
        }
        return (successorDistribution, prefixLength)
    }
    private func skewTowardsTargetPitch(var successorDistribution:[(PitchAndDuration, Frequency)],_ prefixLength:Int) -> ([(PitchAndDuration, Frequency)], Int) {
        let absoluteNote = {(relNote:Int8) -> Int in
            return Int(self.startingPitch) + Int(relNote)
        }
        
        // Cut off
//        successorDistribution = successorDistribution.filter() {
//            return self.inAllowedRange(absoluteNote($0.0.pitch))
//        }
        
        successorDistribution = successorDistribution.map { (pitchWrapper:PitchAndDuration, frequency:Frequency) -> (PitchAndDuration, Frequency) in
            return (pitchWrapper, UInt64(Double(frequency) * self.goodnessOfNote(UInt8(absoluteNote(pitchWrapper.pitch)))))
        }
        
        return (successorDistribution, prefixLength)
    }
    private func goodnessOfNote(note:UInt8) -> Double {
        if let targetPitch = targetPitch {
            let lowestGoodness = 1.0
            let strength = 100.0
            let flexibility = 24.0
            let mean = Double(targetPitch)
            let stdDeviation = max(Double(abs(targetPitch - startingPitch)/2), flexibility)
            
            // Gaussian around target pitch
            let gaussianEvaluated = strength * exp(-(Double(note)-mean)*(Double(note)-mean)/(2*stdDeviation*stdDeviation)) + lowestGoodness
            return gaussianEvaluated
        } else {
            return 1
        }
    }
    private func inAllowedRange(note:Int) -> Bool {
        return self.allowedNoteRange.startIndex <= note && note <= self.allowedNoteRange.endIndex
    }
    private func inMidiRange(note:Int) -> Bool {
        return self.midiNoteRange.startIndex <= note && note <= self.midiNoteRange.endIndex
    }
    
    func trainWith(musicSequence:SwiftMusicSequence, var consideringTracks tracks:[Int]) {
        let trackCount = musicSequence.trackCount
        sort(&tracks)
        for i in tracks {
            if i < trackCount {
                let track = musicSequence.trackWithIndex(i)
                let notes = track.notes
                // TODO Do something about simultaneous notes
                var tokens:SequenceOf<PitchAndDuration>
                if self.relativePitch {
                    tokens = SequenceOf<PitchAndDuration>(toRelativeTokens(notes))
                } else {
                    tokens = SequenceOf<PitchAndDuration>(map(notes, toAbsoluteToken))
                }
                melodyNGram.train(tokens)
                if !embedDuration {
                    var durations:SequenceOf<UInt8> = SequenceOf(map(notes) { return UInt8(self.durationMap.toInt($0.duration)) })
                    durationNGram.train(durations)
                }
            } else {
                break
            }
        }
        
        let stats = reduce(1...maxN, "") { (temp:String, n:Int) -> String in
            return temp + "\n\(self.melodyNGram.countUniqueGramsOfN(n)) \(n)-grams" }
        println("Now trained on \(melodyNGram.frequencyOf([])) tokens. Unique n-grams: \(stats)")
    }
    
    func toRelativeTokens(notes:SequenceOf<MIDINote>) -> SequenceOf<PitchAndDuration> {
        return SequenceOf<PitchAndDuration> { () -> GeneratorOf<PitchAndDuration> in
            var noteGenerator = notes.generate()
            var previousNote = noteGenerator.next()
            return GeneratorOf<PitchAndDuration> { () -> PitchAndDuration? in
                var relativeToken:PitchAndDuration? = nil
                
                if let currentNote = noteGenerator.next() {
                    let pitchChange = Int8(Int(currentNote.note) - Int(previousNote!.note))
                    let duration = self.trainOnDuration(currentNote)
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
        
        var duration = getDurationFrom(token.duration)
        
        return MIDINote(
            timestamp:          timestamp,
            note:               UInt8(pitch),
            duration:           duration
        )
    }
    
    func toAbsoluteToken(midiNote:MIDINote) -> PitchAndDuration {
        var intDuration = trainOnDuration(midiNote)
        return PitchAndDuration(pitch: Int8(midiNote.note), duration: UInt8(intDuration))
    }
    
    func trainOnDuration(midiNote:MIDINote) -> UInt8 {
        return self.embedDuration ? UInt8(self.durationMap.toInt(midiNote.duration)) : UInt8.max
    }
    func getDurationFrom(embeddedInt:UInt8) -> Float32 {
        if !self.embedDuration {
            var limitedPrefix = prefix.count > 0 ? Array(suffix(prefix, n-1)) : []
            var durationPrefix:SequenceOf<UInt8> = SequenceOf(map(limitedPrefix) {
                return UInt8(self.durationMap.toInt($0.duration))
            })
            var durationInt = durationNGram.generateNextFromPrefix(durationPrefix)
            return self.durationMap.toFloat(UInt32(durationInt))!
        } else {
            return self.durationMap.toFloat(UInt32(embeddedInt))!
        }
    }
    
    func fromAbsoluteToken(token:PitchAndDuration, timestamp:Float) -> MIDINote {
        let duration:Float32 = getDurationFrom(token.duration)
        let note = UInt8(token.pitch)
        return MIDINote(timestamp: timestamp, note: note, duration: duration)
    }
    
    func startGeneratingTimedNotes() {
        if generating {
            var limitedPrefix = prefix.count > 0 ? Array(suffix(prefix, n)) : []
            var tokenPrefix:[PitchAndDuration]
            if self.relativePitch {
                tokenPrefix = Array(toRelativeTokens(SequenceOf<MIDINote>(limitedPrefix)))
            } else {
                tokenPrefix = limitedPrefix.map { self.toAbsoluteToken($0) }
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
        }
    }
}