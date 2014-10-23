//
//  DurationMapper.swift
//  SwiftMusic
//
//  Created by Daniel Schlaug on 10/22/14.
//  Copyright (c) 2014 Swift Generation. All rights reserved.
//

import Swift
import Foundation

class DurationMapper {
    private var map:[Float32:UInt32] = [:]
    private var reverse:[Float32] = []
    var maxMappings:UInt64 = UInt64(UInt32.max) + UInt64(UInt32(1))
    private var currentMappings:UInt64 = 0
    
    init(maxMappings:UInt64) {
        self.maxMappings = maxMappings
    }
    
    func toInt(float:Float32) -> UInt32 {
        if let int = map[float] {
            return int
        } else if currentMappings < maxMappings {
            let result = UInt32(currentMappings)
            currentMappings++
            map[float] = result
            reverse.append(float)
            return result
        } else {
            var closestIndex = 0
            var smallestDelta = abs(reverse[0] - float)
            for i in 1..<reverse.count {
                let newDelta = abs(reverse[i] - float)
                if newDelta < smallestDelta {
                    smallestDelta = newDelta
                    closestIndex = i
                }
            }
            return UInt32(closestIndex)
        }
    }
    
    func toFloat(int:UInt32) -> Float32? {
        if Int(int) >= reverse.count {
            return nil
        } else {
            return reverse[Int(int)]
        }
    }
}