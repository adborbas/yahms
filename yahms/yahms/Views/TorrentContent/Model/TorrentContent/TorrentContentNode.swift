//
//  TorrentContentNode.swift
//  yahms
//

import Foundation
import qBittorrent

protocol TorrentContentNode: AnyObject {
    var parent: TorrentContentDirectory? { get set }
    
    var index: Set<Int> { get }
    var name: String { get }
    var size: Int64 { get }
    var progress: Float { get }
    var priority: TorrentContentPriority { get }
}
