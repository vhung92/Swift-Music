//
//  ViewController.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/2/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var nLabel: UILabel!
    @IBOutlet weak var targetPitchLabel: UILabel!
    @IBOutlet weak var targetPitchSwitch: UISwitch!
    @IBOutlet weak var targetPitchSlider: UISlider!
    @IBOutlet weak var nSlider: UISlider!
    @IBOutlet weak var trainingProgressBar: UIProgressView!
    
    var songCount = 10
    var limitedN:Int = 3 {
        didSet {
            nLabel.text = "n = \(limitedN)"
            midiGenerator.n = limitedN
            nSlider.value = Float(limitedN)
        }
    }
    var generatedNotes = 0
    
    let midiView = EndlessMIDIView()
    let midiGenerator = MIDIGenerator(maxN: 5, relativePitch: false, embedDuration:false)

    override func viewDidLoad() {
        super.viewDidLoad()
        nSlider.maximumValue = Float(midiGenerator.n)
        limitedN = Int(nSlider.maximumValue)
        
        midiGenerator.receptor = {
            if ++self.generatedNotes >= 100000 {
                self.midiGenerator.generating = false
                self.generatedNotes = 0
            }
            self.midiView.secondsPerDurationUnit = $1
            self.midiView.playNote($0)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func nSliderChanged(sender: UISlider) {
        let value = Int(ceil(sender.value))
        limitedN = value
    }

    @IBAction func trainButton(sender: UIButton) {
        dispatch_async(dispatch_queue_create(nil, DISPATCH_QUEUE_SERIAL)) { self.trainModel() }
    }
    @IBAction func playButton(sender: UIButton) {
        midiGenerator.startingPitch = 60
        midiGenerator.clearPrefix()
        midiGenerator.secondsPerDurationUnit = 0.7
        midiView.start()
        midiGenerator.generating = true
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(30 * NSEC_PER_SEC)), dispatch_get_main_queue()) { self.midiGenerator.generating = false }
    }
    @IBAction func stopButton(sender: UIButton) {
        midiGenerator.generating = false
    }
    @IBAction func targetPitchSwitchFlipped(sender: UISwitch) {
        if sender.on {
            updateTargetPitch()
        } else {
            midiGenerator.targetPitch = nil
        }
    }
    @IBAction func targetPitchSliderChanged(sender: UISlider) {
        updateTargetPitch()
    }
    
    private func updateTargetPitch() {
        let targetPitch = UInt8(self.targetPitchSlider.value)
        targetPitchLabel.text = "Target pitch: \(targetPitch)"
        midiGenerator.targetPitch = targetPitch
    }
    
    func trainModel() {
        let midis = NSBundle.mainBundle().URLsForResourcesWithExtension("mid", subdirectory: "/MIDI/Evaluation Data")
        var trainedOn = 0
        if let midis = midis {
            var songCount = min(self.songCount, midis.count)
            setProgressBarTo(1/(Float(songCount)+1.0))
            for maybeMidi in midis {
                if let midiURL = maybeMidi as? NSURL {
                    let musicSequence = SwiftMusicSequence(midiData: NSData(contentsOfURL: midiURL)!)
                    midiGenerator.trainWith(musicSequence, consideringTracks: [0])
                    if trainedOn > songCount { break }
                    println("Trained on: \(++trainedOn)")
                }
                setProgressBarTo(Float(trainedOn+1)/(Float(songCount)+1.0))
            }
        }

    }
    
    func setProgressBarTo(value:Float) {
        dispatch_async(dispatch_get_main_queue()) {
            self.trainingProgressBar.setProgress(value, animated: true)
        }
    }
}

