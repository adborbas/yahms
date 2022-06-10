//
//  TorrentState+localisation.swift
//  yahms
//

import Foundation
import qBittorrent

extension TorrentState {
    var localisedKey: String {
        return "torrent_state_\(self.rawValue)"
    }
}
