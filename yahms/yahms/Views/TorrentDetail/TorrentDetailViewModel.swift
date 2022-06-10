//
//  TorrentDetailViewModel.swift
//  yahms
//

import Foundation
import SwiftUI
import qBittorrent

class TorrentDetailViewModel: ObservableObject {
    @Published var isLoading = false
    
    let torrentHash: String
    @Published var name: String
    @Published var progress: Float
    
    @Published var state: TorrentState
    @Published var size: Int64
    @Published var eta: Int
    @Published var dateAdded: Date
    
    @Published var category = ""
    @Published var location = ""
    
    @Published var seeds = 0
    @Published var seedsTotal = 0
    @Published var peers = 0
    @Published var peersTotal = 0
    
    @Published var downloadSpeed: Int64
    @Published var downloadSpeedAvg: Int64 = 0
    @Published var uploadSpeed: Int64
    @Published var uploadSpeedAvg: Int64 = 0
    
    var remaining: Int64 {
        return Int64(Float(size) * (1.0 - progress))
    }
    
    required init(torrentHash: String,
                  name: String,
                  progress: Float,
                  state: TorrentState,
                  size: Int64,
                  eta: Int,
                  dateAdded: Date,
                  downloadSpeed: Int64,
                  uploadSpeed: Int64) {
        self.torrentHash = torrentHash
        self.name = name
        self.progress = progress
        self.state = state
        self.size = size
        self.eta = eta
        self.dateAdded = dateAdded
        self.downloadSpeed = downloadSpeed
        self.uploadSpeed = uploadSpeed
    }
    
    convenience init(torrentInfo: TorrentInfoRowViewModel) {
        self.init(torrentHash: torrentInfo.hash,
                  name: torrentInfo.name,
                  progress: torrentInfo.progress,
                  state: torrentInfo.state,
                  size: torrentInfo.size,
                  eta: torrentInfo.eta,
                  dateAdded: torrentInfo.dateAdded,
                  downloadSpeed: torrentInfo.downloadSpeed,
                  uploadSpeed: torrentInfo.uploadSpeed)
    }
}
