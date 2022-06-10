//
//  AddTorrentViewModel.swift
//  yahms
//

import Foundation
import Combine

struct TorrentCategory: Hashable {
    let name: String
    let savePath: String
}

class AddTorrentViewModel: ObservableObject {
    @Published var isAddLoading = false
    @Published var isLoadingProperties = false
    
    @Published var categories = [TorrentCategory]()
    @Published var selectedCategory = "series"
    @Published var torrentPath: URL?
    @Published var startTorrent = true
    @Published var autoManagement = true
    @Published var savePath = ""
    @Published var sequentialDownload = false
    @Published var firstLastPiecePrio = false
    
    var isAddValid: Bool {
        return torrentPath != nil
    }
    
    var torrentName: String {
        guard let torrentPath = torrentPath else { return "" }
        
        return torrentPath.deletingPathExtension().lastPathComponent
    }
    
    var categorySavePath: String {
        return categories.first { $0.name == selectedCategory }?.savePath ?? ""
    }
}
