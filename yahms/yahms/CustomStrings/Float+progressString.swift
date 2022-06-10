//
//  Float+progressString.swift
//  yahms
//

import Foundation

extension Float {
    var progressString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
