//
//  TorrentContentPriority.swift
//  yahms
//

import Foundation
import qBittorrent

enum TorrentContentPriority: Int, CaseIterable, Identifiable, Comparable, Equatable {
    case mixed = 0
    case skip
    case normal
    case high
    case maximum
    
    var id: Int {
        return self.rawValue
    }
    
    var text: String {
        switch self {
        case .mixed:
            return NSLocalizedString("torrent_content_priority_mixed", comment: "")
        case .skip:
            return NSLocalizedString("torrent_content_priority_skip", comment: "")
        case .normal:
            return NSLocalizedString("torrent_content_priority_normal", comment: "")
        case .high:
            return NSLocalizedString("torrent_content_priority_high", comment: "")
        case .maximum:
            return NSLocalizedString("torrent_content_priority_maximum", comment: "")
        }
    }
    
    static func < (lhs: TorrentContentPriority, rhs: TorrentContentPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

extension TorrentContentPriority {
    init(_ priority: TorrentContent.Priority) {
        switch priority {
        case .doNotDownload:
            self = .skip
        case .normal:
            self = .normal
        case .high:
            self = .high
        case .maximum:
            self = .maximum
        }
    }
}

extension TorrentContentPriority {
    var asQBittorrentPrioroty: TorrentContent.Priority? {
        switch self {
        case .skip:
            return .doNotDownload
        case .normal:
            return .normal
        case .high:
            return .high
        case .maximum:
            return .maximum
        case .mixed:
            return nil
        }
    }
}
