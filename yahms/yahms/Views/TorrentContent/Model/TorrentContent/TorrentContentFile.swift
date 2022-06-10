//
//  TorrentContentFile.swift
//  yahms
//

import Foundation

class TorrentContentFile: TorrentContentNode {
    weak var parent: TorrentContentDirectory?
    
    private let _index: Int
    var index: Set<Int> {
        return [_index]
    }
    
    let name: String
    let size: Int64
    let progress: Float
    let priority: TorrentContentPriority
    
    init(index: Int, name: String, size: Int64, progress: Float, priority: TorrentContentPriority) {
        self._index = index
        self.name = name
        self.size = size
        self.progress = progress
        self.priority = priority
    }
}
