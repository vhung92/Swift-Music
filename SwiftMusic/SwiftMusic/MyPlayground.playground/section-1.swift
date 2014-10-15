// Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"



struct Token: Hashable {
    let content:Int8
    
    var hashValue: Int {
        return Int(content)
    }
    
    func ==(lhs: Token, rhs: Token) -> Bool {
    return lhs.content == rhs.content
    }
}