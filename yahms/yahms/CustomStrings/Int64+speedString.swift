//
//  Int64+speedString.swift
//  yahms
//

import Foundation

extension Int64 {
    var speedString: String {
        if self == 0 {
            return NSLocalizedString("zero_speed_text", comment: "")
        }
        
        return String(format: NSLocalizedString("speed_per_second_text", comment: ""), sizeString)
    }
    
    var sizeString: String {
        return ByteCountFormatter.string(fromByteCount: self, countStyle: .memory)
    }
}
