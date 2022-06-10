//
//  Int+etaString.swift
//  yahms
//

import Foundation

extension Int {
    var etaString: String {
        if self == 8_640_000 {
            return NSLocalizedString("infinity_sign", comment: "")
        }
        
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        
        return formatter.string(from: TimeInterval(self)) ?? ""
    }
}
