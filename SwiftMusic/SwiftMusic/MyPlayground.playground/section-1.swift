// Playground - noun: a place where people can play

import UIKit
import AudioToolbox

var description = AudioComponentDescription(componentType: OSType(kAudioUnitType_MusicDevice), componentSubType: OSType(kAudioUnitSubType_Sampler), componentManufacturer: 0, componentFlags: 0, componentFlagsMask: 0)

var name:CFStringRef
var audioComponent = AudioComponent()
audioComponent = AudioComponentFindNext(audioComponent, &description)
AudioComponentGetDescription(audioComponent, &description)
description

var array = [3,2,1]
sort(&array)
array

var durationBits:UInt32 = 127
durationBits = durationBits << 8
durationBits = 0x0000FF00 & UInt32(Int(durationBits))
durationBits = durationBits >> 8

61 | 256