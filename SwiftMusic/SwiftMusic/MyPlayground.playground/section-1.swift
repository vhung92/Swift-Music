// Playground - noun: a place where people can play

import UIKit
import AudioToolbox

var description = AudioComponentDescription(componentType: OSType(kAudioUnitType_MusicDevice), componentSubType: OSType(kAudioUnitSubType_Sampler), componentManufacturer: 0, componentFlags: 0, componentFlagsMask: 0)

var name:CFStringRef
var audioComponent = AudioComponent()
audioComponent = AudioComponentFindNext(audioComponent, &description)
AudioComponentGetDescription(audioComponent, &description)
description
AudioComponentCopyName(<#inComponent: AudioComponent#>, <#outName: UnsafeMutablePointer<Unmanaged<CFString>?>#>)