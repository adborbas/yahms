//
//  AddHostPresenter.swift
//  yahms
//

import Foundation
import Combine
import qBittorrent

class AddHostPresenter {
    private(set) var viewModel: AddHostViewModel
    
    private var subscriptions: Set<AnyCancellable> = []
    private let hostStorage: HostStorage
    let mode: AddHostView.Mode
    
    init(hostStorage: HostStorage,
         mode: AddHostView.Mode) {
        self.hostStorage = hostStorage
        self.viewModel = AddHostViewModel()
        self.mode = mode
        
        if case .edit(let host) = mode {
            updateViewModel(from: host)
        }
    }
    
    func addHost(_ completionHandler: @escaping (String?) -> ()) {
        guard let host = hostFromViewModel() else {
            return
        }
        
        viewModel.isAddLoading = true
        
        let qBittorrentService = MainResolver.shared.resolveQBittorrentService(with: host)
        qBittorrentService.webAPIVersion()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.viewModel.isAddLoading = false
                    switch error {
                    case .forbidden:
                        completionHandler("Invalid username or password.")
                    default:
                        completionHandler("\(error.localizedDescription)")
                    }
                case .finished:
                    break
                }
            } receiveValue: { semver in
                guard semver < Semver(3,0,0) else {
                    completionHandler("The found qBittorrent qBittorrent WebUI API version (\(semver)) is unsupported. Please provide a version of qBittorrent WebUI API with 2.x.x")
                    return
                }
                
                self.hostStorage.add(host)
                    .sink { completion in
                        self.viewModel.isAddLoading = false
                        switch completion {
                        case .failure(let error):
                            completionHandler("\(error.localizedDescription)")
                        case .finished:
                            break
                        }
                    } receiveValue: { _ in
                        completionHandler(nil)
                    }
                    .store(in: &self.subscriptions)
            }
            .store(in: &subscriptions)
    }
    
    func editHost(_ completionHandler: @escaping (String?) -> ()) {
        guard let host = hostFromViewModel() else {
            return
        }
        
        viewModel.isAddLoading = true
        
        hostStorage.update(hostWithId: host.id, to: host)
            .sink { [viewModel] completion in
                viewModel.isAddLoading = false
                switch completion {
                case .failure(let error):
                    completionHandler("\(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { _ in
                completionHandler(nil)
            }
            .store(in: &subscriptions)
    }
    
    private func updateViewModel(from host: Host) {
        guard let schemeString = host.url.scheme,
              let scheme = AddHostViewModel.URLScheme(rawValue: schemeString),
              let urlHost = host.url.host,
              let port = host.url.port else { return }
        viewModel.selectedScheme = scheme
        viewModel.server = urlHost
        viewModel.port = port
        viewModel.name = host.name
        switch host.authentication {
        case .bypassed:
            viewModel.isAuthenticationEnabled = false
        case .basicAuth(let credentials):
            viewModel.isAuthenticationEnabled = true
            viewModel.username = credentials.username
            viewModel.password = credentials.password
        }
        viewModel.icon = host.icon
    }
    
    private func hostFromViewModel() -> Host? {
        var components = URLComponents()
        components.scheme = viewModel.selectedScheme.rawValue
        components.host = viewModel.server
        components.port = viewModel.port ?? viewModel.defaultPort
        guard let url = components.url else { return nil }
        
        var authentication: Host.Authentication = .bypassed
        if viewModel.isAuthenticationEnabled {
            authentication = .basicAuth(Host.BasicAuthCredentials(username: viewModel.username,
                                                                  password: viewModel.password))
        }
        
        let id: String
        switch mode {
        case .add:
            id = UUID().uuidString
        case .edit(let host):
            id = host.id
        }
        let name = !viewModel.name.isEmpty ? viewModel.name : viewModel.server
        return Host(
            id: id,
            name: name,
            url: url,
            icon: viewModel.icon,
            authentication: authentication)
    }
}
