//
//  EndlessMIDIView.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/21/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Foundation
import AVFoundation

public class EndlessMIDIView {
    private let engine = AVAudioEngine()
    private let sampler:AVAudioUnitSampler
    private let stopQueue = dispatch_queue_create(nil, DISPATCH_QUEUE_CONCURRENT)
    private let bps:Double = 2.0

    
    init() {
        let playerNode = AVAudioPlayerNode()
        engine.attachNode(playerNode)
        let mixer = engine.mainMixerNode
        engine.connect(playerNode, to: mixer, format: mixer.outputFormatForBus(0))
        sampler = AVAudioUnitSampler()
        engine.attachNode(sampler)
        engine.connect(sampler, to: engine.outputNode, format: nil)
        
        
        let soundbank = NSBundle.mainBundle().URLForResource("acoustic_grand_piano_ydp_20080910", withExtension: "sf2")
        let melodicBank = UInt8(kAUSampler_DefaultMelodicBankMSB)
        var error:NSError?
        if !sampler.loadSoundBankInstrumentAtURL(soundbank, program: 0, bankMSB: melodicBank, bankLSB: 0, error: &error) {
            println("could not load soundbank")
        }
        if let e = error {
            println("error \(e.localizedDescription)")
        }
    }
    
    public func startNote(note:UInt8, withVelocity: UInt8, onChannel: UInt8) {
        sampler.startNote(note, withVelocity: withVelocity, onChannel: onChannel)
    }
    
    public func stopNote(note:UInt8, onChannel:UInt8) {
        sampler.stopNote(note, onChannel: onChannel)
    }
    
    public func playNote(midiEvent:MIDINote) {
        startNote(midiEvent.note, withVelocity: midiEvent.velocity, onChannel: midiEvent.channel)
        var durationInQuarternotes = Float(midiEvent.duration)
        var durationInNanosec = Int64((Double(durationInQuarternotes) * Double(NSEC_PER_SEC)) / bps)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, durationInNanosec), stopQueue) {
            self.stopNote(midiEvent.note, onChannel:midiEvent.channel)
        }
    }
    
    public func start() {
        var error:NSError?
        if !engine.startAndReturnError(&error) {
            println("error couldn't start engine")
            if let e = error {
                println("error \(e.localizedDescription)")
            }
        }
    }
    
    
}