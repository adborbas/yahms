//
//  SecureHostStorage.swift
//  yahms
//

import Foundation
import Combine
import SwiftUI

class SecureHostStorage: HostStorage {
    private enum Constants {
        static let hostsKey = "KEY_HOSTS"
    }
    
    @AppStorage("last_selected_host_id")
    var lastSelectedHostId: String?
    
    private let secureStore: SecureStorage
    
    init(secureStore: SecureStorage) {
        self.secureStore = secureStore
    }
    
    func hosts() -> AnyPublisher<[Host], HostStorageError> {
        return Future<[Host], Error> { promise in
            guard let rawHosts = self.secureStore.getData(for: Constants.hostsKey) else {
                promise(.success([]))
                return
            }
            
            do {
                let hosts = try JSONDecoder().decode([Host].self, from: rawHosts)
                promise(.success(hosts))
            }
            catch {
                promise(.failure(HostStorageError.hostsCouldNotBeRead(error)))
            }
        }
        .mapError { self.handleError($0) }
        .eraseToAnyPublisher()
    }
    
    func add(_ host: Host) -> AnyPublisher<Bool, HostStorageError> {
        return hosts()
            .tryMap { hosts -> Bool in
                if hosts.contains(where: { $0.url == host.url }) {
                    throw HostStorageError.hostWithSameURL
                }
                
                var extendedHosts = hosts
                extendedHosts.append(host)
                
                try self.upsert(extendedHosts)
                return true
            }
            .mapError { self.handleError($0) }
            .eraseToAnyPublisher()
    }
    
    func update(hostWithId: String, to updatedHost: Host) -> AnyPublisher<Bool, HostStorageError> {
        return hosts()
            .tryMap { hosts -> Bool in
                guard let indexOfHost = hosts.firstIndex(where: { $0.id == hostWithId}) else {
                    throw HostStorageError.hostNotFound
                }
                
                var updatedHosts = hosts
                updatedHosts[indexOfHost] = updatedHost
                
                try self.upsert(updatedHosts)
                return true
            }
            .mapError { self.handleError($0) }
            .eraseToAnyPublisher()
    }
    
    func delete(_ host: Host) -> AnyPublisher<Bool, HostStorageError> {
        return hosts()
            .tryMap { hosts -> Bool in
                guard let hostIndex = hosts.firstIndex(of: host) else {
                    throw HostStorageError.hostNotFound
                }
                var modifiedHosts = hosts
                modifiedHosts.remove(at: hostIndex)
                
                try self.upsert(modifiedHosts)
                return true
            }
            .mapError { self.handleError($0) }
            .eraseToAnyPublisher()
    }
    
    private func upsert(_ hosts: [Host]) throws {
        let data = try JSONEncoder().encode(hosts)
        guard self.secureStore.setData(data, for: Constants.hostsKey) else {
            throw HostStorageError.hostsCouldNotBeStored
        }
    }
    
    private func handleError(_ error: Error) -> HostStorageError {
        switch error {
        case let error as HostStorageError:
            return error
        default:
            return .wrapped(error)
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self) else {
            return "[]"
        }
              
        guard let rawString = String(data: data, encoding: .utf8) else {
            return "[]"
        }
        
        return rawString
    }
}
