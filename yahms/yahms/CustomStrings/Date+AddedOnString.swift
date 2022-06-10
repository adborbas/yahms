//
//  Date+AddedOnString.swift
//  yahms
//

import Foundation

extension Date {
    var addedOnString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale.current
        
        return dateFormatter.string(from: self)
    }
}
