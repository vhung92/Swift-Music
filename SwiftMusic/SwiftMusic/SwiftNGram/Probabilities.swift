//
//  Probabilities.swift
//  DanielsKit
//
//  Created by Daniel Schlaug on 7/14/14.
//  Copyright (c) 2014 Daniel Schlaug. All rights reserved.
//

import Foundation

let distribution = [40, 30, 20, 10]

func randomIndexFromDistribution(distribution:[Double]) -> Int {
    let sum = distribution.reduce(0){$0+$1}
    let random = drand48()*sum
    var index = 0
    var lastBoundry = 0.0
    for (candIndex, probabilityMass) in enumerate(distribution) {
        let newBoundry = lastBoundry + probabilityMass
        if lastBoundry <= random && random < newBoundry {
            index = candIndex
            break
        }
        lastBoundry = newBoundry
    }
    return index
}
    
