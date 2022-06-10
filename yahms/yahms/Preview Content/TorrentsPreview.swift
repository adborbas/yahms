//
//  TorrentsPreview.swift
//  yahms
//

import qBittorrent
import Foundation

enum Preview {
    
}

extension Preview {
    enum TorrentInfoData {
        static let stalledUP = TorrentInfoRowViewModel(name: "StalledUP.Torrent.StalledUP.Torrent.StalledUP.Torrent.StalledUP.Torrent",
                                                       downloadSpeed: 10000,
                                                       uploadSpeed: 12000,
                                                       state: .downloading,
                                                       category: "movies",
                                                       hash: "dasdajlksdhakhjsdh",
                                                       progress: 1.0,
                                                       eta: 100,
                                                       size: 1000000,
                                                       dateAdded: Date())
        
        static let missingFiles = TorrentInfoRowViewModel(name: "MissingFiles.Torrent.MissingFiles.Torrent.MissingFiles.Torrent",
                                                          downloadSpeed: 10000,
                                                          uploadSpeed: 12000,
                                                          state: .missingFiles,
                                                          category: "series",
                                                          hash: "dasdajlksdhdasdaakhjsdh",
                                                          progress: 0.5,
                                                          eta: 50,
                                                          size: 23487389,
                                                          dateAdded: Date())
        
        static func withState(_ state: TorrentState) -> TorrentInfoRowViewModel {
            TorrentInfoRowViewModel(name: "\(state.rawValue).yolo.xdddd.lolll.mkv",
                                    downloadSpeed: Int64.random(in: 0...100000),
                                    uploadSpeed: Int64.random(in: 0...100000),
                                    state: state,
                                    category: "series",
                                    hash: UUID().uuidString,
                                    progress: Float.random(in: 0.0...1.0),
                                    eta: Int.random(in: 0...84600),
                                    size: Int64.random(in: 10000...100000000),
                                    dateAdded: Date().addingTimeInterval(Double.random(in: 1...12) * -3600))
        }
        
        static func allState() -> [TorrentInfoRowViewModel] {
            return TorrentState.allCases.map { withState($0) }
        }
    }
    
    enum TorrentListData {
        static func allState() ->  [TorrentInfoRowViewModel] {
            return TorrentInfoData.allState()
        }
    }
}
