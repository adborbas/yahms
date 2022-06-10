//
//  TorrentContentViewModel.swift
//  yahms
//

import Foundation
import Combine

class TorrentContentViewModel: ObservableObject {
    @Published var content = [TorrentContentRowViewModel]()
    @Published var selection = Set<TorrentContentRowViewModel.ID>()
    @Published var isLoading = false
    @Published var parentDirectoryName = ""
    @Published var sortCategories: [TorrentSortProperties.ContentCategory] = [.name, .size, .priority]
    @Published var selectedSortCategory: TorrentSortProperties.ContentCategory.ID
    @Published var selectedSortDirection: TorrentSortProperties.Direction
    var torrentHash: String
    
    init(torrentHash: String,
         selectedSortCategory: TorrentSortProperties.ContentCategory.ID,
         selectedSortDirection: TorrentSortProperties.Direction) {
        self.torrentHash = torrentHash
        self.selectedSortCategory = selectedSortCategory
        self.selectedSortDirection = selectedSortDirection
    }
    
    func selectAll() {
        selection = Set(content.map { $0.id })
    }
    
    func deselectAll() {
        selection = Set<TorrentContentRowViewModel.ID>()
    }
}
