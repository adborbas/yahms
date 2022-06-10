//
//  TorrentListPresenter.swift
//  yahms
//

import Combine
import Foundation
import qBittorrent

class TorrentsListPresenter {
    private var subscriptions: Set<AnyCancellable> = []
    private var viewModelSubscriptions: Set<AnyCancellable> = []
    private let qBittorrentService: qBittorrentService
    private(set) lazy var viewModel: TorrentListViewModel = {
        return TorrentListViewModel(selectedSortCategory: settingsStorage.torrentListSortCategoryId, selectedSortDirection: settingsStorage.torrentListSortDirection)
    }()
    private var allTorrents = [TorrentInfoRowViewModel]()
    private let settingsStorage: SettingsStorage
    
    init(qBittorrentService: qBittorrentService, settingsStorage: SettingsStorage) {
        self.qBittorrentService = qBittorrentService
        self.settingsStorage = settingsStorage
        
        subscribeToViewModelChanges()
    }
    
    func loadTorrents() {
        subscriptions.forEach { $0.cancel() }
        subscriptions = []
        viewModel.isLoading = true
        
        qBittorrentService.torrents(hash: nil)
            .subscribe(on: DispatchQueue.main)
            .sink { completion in
                self.viewModel.isLoading = false
            } receiveValue: { torrents in
                self.allTorrents = torrents.map { info in
                    return TorrentInfoRowViewModel(name: info.name,
                                                   downloadSpeed: info.downloadSpeed,
                                                   uploadSpeed: info.uploadSpeed,
                                                   state: info.state,
                                                   category: info.category,
                                                   hash: info.hash,
                                                   progress: info.progress,
                                                   eta: info.eta,
                                                   size: info.size,
                                                   dateAdded: info.addedDate)
                }
                self.updateTorrents()
            }.store(in: &subscriptions)
    }
    
    private func subscribeToViewModelChanges() {
        viewModel.$searchQuery
            .sink { searchQuery in
                self.updateTorrents(searchTerm: searchQuery)
            }
            .store(in: &viewModelSubscriptions)
        
        viewModel.$selectedSortCategory
            .dropFirst()
            .sink { newCategory in
                if newCategory == self.viewModel.selectedSortCategory {
                    self.viewModel.selectedSortDirection = self.viewModel.selectedSortDirection.toggling()
                } else {
                    self.viewModel.selectedSortDirection = .descending
                }
                self.settingsStorage.torrentListSortCategoryId = newCategory
                self.settingsStorage.torrentListSortDirection = self.viewModel.selectedSortDirection
                
                self.updateTorrents(sortCategory: newCategory)
            }
            .store(in: &viewModelSubscriptions)
    }
    
    private func updateTorrents(searchTerm: String? = nil, sortCategory: String? = nil) {
        let searchQuery = searchTerm ?? viewModel.searchQuery
        let sortCategory = TorrentSortProperties.InfoCategory(rawValue: sortCategory ?? viewModel.selectedSortCategory) ?? .name
        
        let lowercasedSearchQuery = searchQuery.lowercased()
        
        viewModel.torrents = allTorrents
            .filter({ rowViewModel in
                guard !lowercasedSearchQuery.isEmpty else {
                    return true
                }
                
                return rowViewModel.name.lowercased().contains(lowercasedSearchQuery)
            })
            .sorted(by: { lvm, rvm in
                let result = sortCategory.sort(lvm, rvm)
                if viewModel.selectedSortDirection == .descending {
                    return !result
                }
                return result
            })
    }
}
