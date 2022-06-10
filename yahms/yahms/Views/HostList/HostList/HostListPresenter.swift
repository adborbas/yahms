//
//  HostListPresenter.swift
//  yahms
//

import Foundation
import Combine
import KeychainSwift

class HostListPresenter {
    private(set) lazy var viewModel: HostListViewModel = {
        return HostListViewModel()
    }()
    
    private var subscriptions: Set<AnyCancellable> = []
    private let hostStorage: HostStorage
    private let secureStore = KeychainSwift()
    
    private var hosts = [Host]() {
        didSet {
            viewModel.hosts = hosts.map { HostRowViewModel(host: $0) }
        }
    }
    
    init(hostStorage: HostStorage) {
        self.hostStorage = hostStorage
    }
    
    func viewAppeared() {
        subscriptions.forEach { $0.cancel() }
        subscriptions = []
        
        subscribeToLastSelectedHostIdChange()
        loadHosts()
    }
    
    func loadHosts() {
        viewModel.isLoading = true
        viewModel.lastSelectedHostId = hostStorage.lastSelectedHostId
        
        hostStorage.hosts()
            .subscribe(on: DispatchQueue.main)
            .sink { _ in
                self.viewModel.isLoading = false
            } receiveValue: { hosts in
                self.hosts = hosts
            }
            .store(in: &subscriptions)
    }
    
    func deleteSelectedHost() {
        guard let host = viewModel.selectedHost else { return }
        
        hostStorage.delete(host)
            .sink(receiveCompletion: { _ in
                self.loadHosts()
            }, receiveValue: { _ in
                
            })
            .store(in: &subscriptions)
    }
    
    private func subscribeToLastSelectedHostIdChange() {
        viewModel.$lastSelectedHostId
            .dropFirst()
            .sink { id in
                self.hostStorage.lastSelectedHostId = id
            }
            .store(in: &subscriptions)
    }
}
