//
//  TorrentDetailPresenter.swift
//  yahms
//

import Foundation
import Combine
import qBittorrent

class TorrentDetailPresenter {
    
    private var subscriptions: Set<AnyCancellable> = []
    private let qBittorrentService: qBittorrentService
    private(set) var viewModel: TorrentDetailViewModel
    
    init(torrentInfo: TorrentInfoRowViewModel, qBittorrentService: qBittorrentService) {
        self.viewModel = TorrentDetailViewModel(torrentInfo: torrentInfo)
        self.qBittorrentService = qBittorrentService
        updateViewModelFrom(torrentInfoRow: torrentInfo)
    }
    
    func reloadData() {
        viewModel.isLoading = true
        let properties = qBittorrentService.torrentGenericProperties(hash: viewModel.torrentHash)
        let info =  qBittorrentService.torrents(hash: viewModel.torrentHash)
        properties.combineLatest(info).sink { completion in
            self.viewModel.isLoading = false
            if case .failure(let error) = completion {
                print("Failed to reload data: \(error.localizedDescription)")
            }
        } receiveValue: { properties, infos in
            self.updateViewModelFrom(properties: properties)
            if let info = infos.first {
                self.updateViewModelFrom(torrentInfo: info)
            }
        }
        .store(in: &subscriptions)
        
    }
    
    func deleteTorrent(deleteFiles: Bool, _ completionHandler: @escaping (Bool) -> ()) {
        viewModel.isLoading = true
        qBittorrentService.deleteTorrent(hash: viewModel.torrentHash, deleteFiles: deleteFiles).sink { completion in
            self.viewModel.isLoading = false
            switch completion {
            case .failure(let error):
                print(error)
            case .finished:
                return
            }
            
            completionHandler(false)
        } receiveValue: { _ in
            self.viewModel.isLoading = false
            completionHandler(true)
        }
        .store(in: &subscriptions)
        
    }
    
    private func updateViewModelFrom(properties: TorrentGenericProperties) {
        viewModel.size = properties.totalSize
        viewModel.uploadSpeed = properties.uploadSpeed
        viewModel.uploadSpeedAvg = properties.uploadSpeedAvg
        viewModel.downloadSpeed = properties.downloadSpeed
        viewModel.downloadSpeedAvg = properties.downloadSpeedAvg
        viewModel.seeds = properties.seeds
        viewModel.seedsTotal = properties.seedsTotal
        viewModel.peers = properties.peers
        viewModel.peersTotal = properties.peersTotal
        viewModel.location = properties.savePath
        viewModel.eta = properties.eta
    }
    
    private func updateViewModelFrom(torrentInfo: TorrentInfo) {
        viewModel.name = torrentInfo.name
        viewModel.progress = torrentInfo.progress
        viewModel.state = torrentInfo.state
        viewModel.category = torrentInfo.category
    }
    
    private func updateViewModelFrom(torrentInfoRow: TorrentInfoRowViewModel) {
        viewModel.name = torrentInfoRow.name
        viewModel.downloadSpeed = torrentInfoRow.downloadSpeed
        viewModel.eta = torrentInfoRow.eta
        viewModel.progress = torrentInfoRow.progress
        viewModel.uploadSpeed = torrentInfoRow.uploadSpeed
        viewModel.state = torrentInfoRow.state
        viewModel.category = torrentInfoRow.category
        viewModel.progress = torrentInfoRow.progress
    }
}
