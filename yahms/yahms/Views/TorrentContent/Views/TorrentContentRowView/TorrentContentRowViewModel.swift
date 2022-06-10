//
//  TorrentContentRowViewModel.swift
//  yahms
//

import Foundation

class TorrentContentRowViewModel: ObservableObject, Identifiable, Hashable {
    @Published var name: String
    @Published var isDirectory: Bool
    @Published var size: Int64
    @Published var progress: Float
    @Published var priority: TorrentContentPriority
    @Published var index: Set<Int>
    
    private var downloaded: Int64 {
        return Int64(Double(size) * Double(progress))
    }
    
    var totalAndRemainingText: String {
        return String(format: NSLocalizedString("torrent_content_total_remaining_text", comment: ""),
                      downloaded.sizeString, size.sizeString)
    }
    
    init(index: Set<Int>,
          name: String,
          isDirectory: Bool,
          size: Int64,
          progress: Float,
          priority: TorrentContentPriority) {
        self.index = index
        self.name = name
        self.isDirectory = isDirectory
        self.size = size
        self.progress = progress
        self.priority = priority
    }
    
    var id: String {
        return name
    }
    
    static func == (lhs: TorrentContentRowViewModel, rhs: TorrentContentRowViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
