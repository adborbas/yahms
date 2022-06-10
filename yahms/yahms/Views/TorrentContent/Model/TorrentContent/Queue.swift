//
//  Queue.swift
//  yahms
//

import Foundation

// Based on https://github.com/raywenderlich/swift-algorithm-club/blob/master/Queue/Queue-Simple.swift
struct Queue<T> {
    private var array: [T]
    
    var count: Int {
        return array.count
    }
    
    var isEmpty: Bool {
        return array.isEmpty
    }
    
    var peek: T? {
        return array.first
    }
    
    init(_ item: T? = nil) {
        if let item = item {
            self.array = [item]
        } else {
            self.array = [T]()
        }
    }
    
    mutating func enqueue(_ element: T) {
        array.append(element)
    }
    
    mutating func dequeue() -> T? {
        if isEmpty {
            return nil
        } else {
            return array.removeFirst()
        }
    }
}
