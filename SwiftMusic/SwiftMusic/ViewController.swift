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

    override func viewDidLoad() {
        super.viewDidLoad()
        midiView.start()
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(1) * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                self.midiView.startNote(60, withVelocity: 60, onChannel: 1)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

