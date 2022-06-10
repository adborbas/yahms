//
//  TorrentContentPresenter.swift
//  yahms
//

import Combine
import Foundation
import qBittorrent

class TorrentContentPresenter {
    private var subscriptions: Set<AnyCancellable> = []
    private let qBittorrentService: qBittorrentService
    private let viewModelMapper: TorrentContentViewModelMapper
    private let torrentContentCache: TorrentContentCache
    private let settingsStorage: SettingsStorage
    
    private(set) lazy var viewModel: TorrentContentViewModel = {
        return TorrentContentViewModel(
            torrentHash: torrentHash,
            selectedSortCategory: settingsStorage.torrentContentSortCategoryId,
            selectedSortDirection: settingsStorage.torrentContentSortDirection)
    }()
    let torrentHash: String
    let contentDirectoryPath: TorrentDirectoryPath
    
    init(qBittorrentService: qBittorrentService,
         viewModelMapper: TorrentContentViewModelMapper,
         torrentContentCache: TorrentContentCache,
         settingsStorage: SettingsStorage,
         torrentHash: String,
         contentDirectoryPath: TorrentDirectoryPath) {
        self.qBittorrentService = qBittorrentService
        self.viewModelMapper = viewModelMapper
        self.torrentContentCache = torrentContentCache
        self.settingsStorage = settingsStorage
        self.torrentHash = torrentHash
        self.contentDirectoryPath = contentDirectoryPath
    }
    
    func viewAppear() {
        subscribeToSelectedCategoryChange()
        loadTorrentContent(isForced: false)
    }
    
    func viewDisappear() {
        subscriptions.forEach { $0.cancel() }
        subscriptions.removeAll()
    }
    
    func loadTorrentContent(isForced: Bool) {
        if isForced {
            loadContentsFromService()
            return
        }
        
        guard let cachedDirectory = torrentContentCache.getContentDirectory() else {
            loadContentsFromService()
            return
        }
        
        updateViewModel(from: cachedDirectory, at: contentDirectoryPath)
    }
    
    func setPriority(_ to: TorrentContentPriority, _ completionHandler: @escaping (Bool) -> ()) {
        viewModel.isLoading = true
        guard let priority = to.asQBittorrentPrioroty else {
            completionHandler(false)
            return
        }
        
        let contentToChangePriority = viewModel.content.filter { content in
            return viewModel.selection.contains(content.id)
        }
        var indexes = Set<Int>()
        contentToChangePriority.forEach { rowViewModel in
            rowViewModel.index.forEach { indexes.insert($0) }
        }
        qBittorrentService.setFilePriority(hash: viewModel.torrentHash, files: indexes, priority: priority).sink { completion in
            self.viewModel.isLoading = false
            switch completion {
            case .failure(let error):
                print(error)
            case .finished:
                return
            }
            
            self.loadTorrentContent(isForced: true)
            completionHandler(false)
        } receiveValue: { _ in
            self.viewModel.isLoading = false
            completionHandler(true)
        }
        .store(in: &subscriptions)
    }
    
    private func subscribeToSelectedCategoryChange() {
        viewModel.$selectedSortCategory
            .dropFirst()
            .sink { newCategory in
                if newCategory == self.viewModel.selectedSortCategory {
                    self.viewModel.selectedSortDirection = self.viewModel.selectedSortDirection.toggling()
                } else {
                    self.viewModel.selectedSortDirection = .descending
                }
                
                self.settingsStorage.torrentContentSortCategoryId = newCategory
                self.settingsStorage.torrentContentSortDirection = self.viewModel.selectedSortDirection
                
                self.updateViewModel(categoryID: newCategory, direction: self.viewModel.selectedSortDirection)
            }
            .store(in: &subscriptions)
    }
    
    private func loadContentsFromService() {
        viewModel.isLoading = true
        qBittorrentService.torrentContent(hash: torrentHash)
            .subscribe(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("Failed to load torrent content: \(error.localizedDescription)")
                }
                self.viewModel.isLoading = false
            } receiveValue: { contents in
                let contentDirectory = self.viewModelMapper.mapContentsToDirectory(contents)
                self.torrentContentCache.setContentDirectory(contentDirectory)
                
                self.updateViewModel(from: contentDirectory, at: self.contentDirectoryPath)
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewModel(from contentDirectory: TorrentContentDirectory, at path: TorrentDirectoryPath) {
        guard let cachedDirectoryOnPath = contentDirectory.findDirectory(onPath: path) else {
            return
        }
        
        let contents = viewModelMapper.mapDirectoryToContentRowViewModels(cachedDirectoryOnPath)
        updateViewModel(with: contents, directory: cachedDirectoryOnPath.name)
    }
    
    private func updateViewModel(with contents: [TorrentContentRowViewModel]? = nil,
                                 directory: String? = nil,
                                 categoryID: TorrentSortProperties.ContentCategory.ID? = nil,
                                 direction: TorrentSortProperties.Direction? = nil) {
        
        viewModel.parentDirectoryName = directory ?? viewModel.parentDirectoryName
        let sortCategory: TorrentSortProperties.ContentCategory = {
            guard let categoryID = categoryID,
            let category = TorrentSortProperties.ContentCategory(rawValue: categoryID) else {
                return .name
            }
            
            return category
        }()
        
        viewModel.content = (contents ?? viewModel.content)
            .sorted(by: { lvm, rvm in
                let result = sortCategory.sort(lvm, rvm)
                if (direction ?? viewModel.selectedSortDirection) == .descending {
                    return !result
                }
                
                return result
            })
    }
}

protocol TorrentContentCache {
    func getContentDirectory() -> TorrentContentDirectory?
    
    func setContentDirectory(_ directory: TorrentContentDirectory)
}

class MemoryTorrentContentCache: TorrentContentCache {
    private var cachedDirectory: TorrentContentDirectory?
    
    func getContentDirectory() -> TorrentContentDirectory? {
        return cachedDirectory
    }
    
    func setContentDirectory(_ directory: TorrentContentDirectory) {
        cachedDirectory = directory
    }
}
