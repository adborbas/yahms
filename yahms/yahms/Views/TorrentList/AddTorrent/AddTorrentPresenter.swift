//
//  AddTorrentPresenter.swift
//  yahms
//

import Foundation
import qBittorrent
import Combine

class AddTorrentPresenter {
    private var subscriptions: Set<AnyCancellable> = []
    private let qBittorrentService: qBittorrentService
    private(set) var viewModel = AddTorrentViewModel()
    
    private var addTorrentConfiguration: AddTorrentConfiguration {
        let torrentManagement: AddTorrentConfiguration.Management
        if viewModel.autoManagement {
            torrentManagement = .auto(category: viewModel.selectedCategory)
        } else {
            torrentManagement = .manual(savePath: viewModel.savePath)
        }
        return AddTorrentConfiguration(management: torrentManagement,
                                       paused: !viewModel.startTorrent,
                                       sequentialDownload: viewModel.sequentialDownload,
                                       firstLastPiecePrio: viewModel.firstLastPiecePrio)
    }
    
    init(qBittorrentService: qBittorrentService) {
        self.qBittorrentService = qBittorrentService
    }
    
    func addTorrent(_ completionHandler: @escaping (Bool) -> ()) {
        guard let torrentPath = viewModel.torrentPath,
              torrentPath.startAccessingSecurityScopedResource() else { return }
        
        viewModel.isAddLoading = true
        qBittorrentService.addTorrent(torrentFile: torrentPath, configuration: addTorrentConfiguration)
            .sink { completion in
                torrentPath.stopAccessingSecurityScopedResource()
                self.viewModel.isAddLoading = false
                if case .failure(let error) = completion {
                    print("Failed to add torrent: \(error.localizedDescription)")
                    completionHandler(false)
                }
            } receiveValue: { value in
                if value != "Ok." {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            }
            .store(in: &subscriptions)
    }
    
    func loadProperites() {
        viewModel.isLoadingProperties = true
        
        qBittorrentService.categories().combineLatest(qBittorrentService.appPreferences())
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished:
                    print("Categories and preferences loaded successfully.")
                }
                self.viewModel.isLoadingProperties = false
            } receiveValue: { (categories, preferences) in
                self.updateWithCategories(categories)
                self.updateWithPreferences(preferences)
            }
            .store(in: &subscriptions)
    }
    
    private func updateWithCategories(_ categories: [qBittorrent.TorrentCategory]) {
        viewModel.categories = categories.map { TorrentCategory(name: $0.name, savePath: $0.savePath) }
        if let firstCategory = viewModel.categories.first {
            viewModel.selectedCategory = firstCategory.name
        }
    }
    
    private func updateWithPreferences(_ preferences: AppPreferences) {
        viewModel.savePath = preferences.defaultSavePath
        viewModel.startTorrent = !preferences.isStartPausedEnabled
        viewModel.autoManagement = preferences.isAutoTorrentManagementEnabled
    }
}
