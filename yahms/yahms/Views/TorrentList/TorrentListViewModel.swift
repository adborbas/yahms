//
//  TorrentListViewModel.swift
//  yahms
//

import Foundation

class TorrentListViewModel: ObservableObject {
    @Published var torrents = [TorrentInfoRowViewModel]()
    @Published var isLoading = false
    @Published var searchQuery = ""
    @Published var sortCategories: [TorrentSortProperties.InfoCategory] = TorrentSortProperties.InfoCategory.allCases
    @Published var selectedSortCategory: TorrentSortProperties.InfoCategory.ID
    @Published var selectedSortDirection: TorrentSortProperties.Direction
    
    init(selectedSortCategory: TorrentSortProperties.InfoCategory.ID, selectedSortDirection: TorrentSortProperties.Direction) {
        self.selectedSortCategory = selectedSortCategory
        self.selectedSortDirection = selectedSortDirection
    }
}
