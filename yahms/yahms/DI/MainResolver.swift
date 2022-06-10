//
//  MainResolver.swift
//  yahms
//

import Foundation
import qBittorrent
import SwiftUI
import KeychainSwift

class MainResolver {
    #if DEBUG
    static var shared = MainResolver()
    #endif
    
    static var preview: MainResolver = {
        let resolver = MainResolver()
        _ = resolver.resolveQBittorrentService(with: Host(id: "", name: "", url: URL(string: "http://blah.com:443")!, icon: .service, authentication: .bypassed))
        return resolver
    }()
    
    func resolveTorrentsListPresenter(host: Host) -> TorrentsListPresenter {
        return TorrentsListPresenter(qBittorrentService: resolveQBittorrentService(with: host),
                                     settingsStorage: resolveSettingsStorage())
    }
    
    func resolveAddTorrentPresenter() -> AddTorrentPresenter {
        return AddTorrentPresenter(qBittorrentService: resolveQBittorrentService())
    }
    
    func resolveTorrentDetailPresenter(torrentInfo: TorrentInfoRowViewModel) -> TorrentDetailPresenter {
        return TorrentDetailPresenter(torrentInfo: torrentInfo,
                                      qBittorrentService: resolveQBittorrentService())
    }
    
    func resolveTorrentContentPresenter(torrentHash: String,
                                            contentDirectoryPath: TorrentDirectoryPath) -> TorrentContentPresenter {
        return TorrentContentPresenter(qBittorrentService: resolveQBittorrentService(),
                                           viewModelMapper: resolveTorrentContentViewModelMapper(),
                                           torrentContentCache: resolveTorrentContentCache(),
                                           settingsStorage: resolveSettingsStorage(),
                                           torrentHash: torrentHash,
                                           contentDirectoryPath: contentDirectoryPath)
    }
    
    func resolveHostListPresenter() -> HostListPresenter {
        return HostListPresenter(hostStorage: resolveHostStorage())
    }
    
    func resolveAddHostPresenter(mode: AddHostView.Mode) -> AddHostPresenter {
        return AddHostPresenter(hostStorage: resolveHostStorage(),
                                mode: mode)
    }
    
    private var resolvedQBittorrentService: qBittorrentService?
    
    func resolveQBittorrentService(with host: Host) -> qBittorrentService {
        let service: qBittorrentService
        if let port = host.url.port {
            service = qBittorrentWebAPI(scheme: host.scheme, host: host.host, port: port, authentication: host.authentication.asQBittorrentAuthentication)
        }
        else {
            service = qBittorrentWebAPI(scheme: host.scheme, host: host.host, authentication: host.authentication.asQBittorrentAuthentication)
        }
        resolvedQBittorrentService = service
        return service
    }
    
    private func resolveQBittorrentService() -> qBittorrentService {
        guard let resolvedQBittorrentService = resolvedQBittorrentService else {
            fatalError("qBittorrentService not initialized")
        }
        
        return resolvedQBittorrentService
    }
    
    private func resolveTorrentContentViewModelMapper() -> TorrentContentViewModelMapper {
        return DefaultTorrentContentViewModelMapper()
    }
    
    private func resolveTorrentContentCache() -> TorrentContentCache {
        return MemoryTorrentContentCache()
    }
    
    private func resolveSettingsStorage() -> SettingsStorage {
        return UserDefaultsSettingsStorage()
    }
    
    private func resolveHostStorage() -> HostStorage {
        return SecureHostStorage(secureStore: resolveSecureStorage())
    }
    
    private func resolveSecureStorage() -> SecureStorage {
        return KeychainSwift(keyPrefix: "yaqtc")
    }
}

fileprivate extension Host.Authentication {
    var asQBittorrentAuthentication: qBittorrentWebAPI.Authentication {
        switch self {
        case .bypassed:
            return .bypassed
        case .basicAuth(let credentials):
            return .basicAuth(BasicAuthCredentials(username: credentials.username, password: credentials.password))
        }
    }
}

fileprivate extension Host {
    var scheme: qBittorrentWebAPI.Scheme {
        guard let scheme = url.scheme else { return .http }
        
        return scheme == "https" ? .https : .http
    }
    
    var host: String {
        return url.host!
    }
}
