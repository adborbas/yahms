//
//  TorrentInfoRowViewModel.swift
//  yahms
//

import Foundation
import qBittorrent
import SwiftUI

struct TorrentInfoRowViewModel: Hashable, Identifiable {
    let name: String
    let downloadSpeed: Int64
    let uploadSpeed: Int64
    let state: TorrentState
    let category: String
    let hash: String
    let progress: Float
    let eta: Int
    let size: Int64
    let dateAdded: Date
    
    var id: String {
        return hash
    }
    
    var iconName: String {
        switch state {
        case .error, .missingFiles:
            return "exclamationmark.circle.fill"
        case .uploading:
            return "arrow.up.circle.fill"
        case .pausedUP:
            return "pause.circle.fill"
        case .queuedUP, .stalledUP, .checkingUP:
            return "arrow.up.circle.fill"
        case .forcedUP:
            return "arrow.up.circle.fill"
        case .allocating, .downloading, .metaDL:
            return "arrow.down.circle.fill"
        case .pausedDL:
            return "pause.circle.fill"
        case .queuedDL, .stalledDL, .checkingDL, .forcedDL:
            return "arrow.down.circle.fill"
        case .checkingResumeData:
            return "play.circle.fill"
        case .moving:
            return "folder.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch state {
        case .error, .missingFiles:
            return .red
        case .uploading, .forcedUP:
            return .accentColor
        case .pausedUP:
            return .orange
        case .queuedUP, .stalledUP, .checkingUP:
            return .secondary
        case .allocating, .downloading, .metaDL:
            return .accentColor
        case .pausedDL, .queuedDL, .stalledDL, .checkingDL:
            return .secondary
        case .forcedDL:
            return .accentColor
        case .checkingResumeData:
            return .green
        case .moving:
            return .secondary
        case .unknown:
            return .red
        }
    }
}
