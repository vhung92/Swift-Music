//
//  ViewController.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/2/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let midiView = EndlessMIDIView()
    let midiGenerator = MIDIGenerator(maxN: 100)

    override func viewDidLoad() {
        super.viewDidLoad()
        let midiURL = NSBundle.mainBundle().URLForResource("test", withExtension: "mid")!
        let musicSequence = SwiftMusicSequence(midiData: NSData(contentsOfURL: midiURL)!)
        midiGenerator.startingPitch = 80
        midiGenerator.embedDuration = true
        midiGenerator.generateDurations = true
        midiGenerator.trainWith(musicSequence, consideringTracks: [0])
        midiView.start()
        midiGenerator.receptor = { self.midiView.secondsPerDurationUnit = $1; self.midiView.playNote($0) }
        midiGenerator.generating = true
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

