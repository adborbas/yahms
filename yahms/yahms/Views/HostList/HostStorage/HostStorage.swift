//
//  HostStorage.swift
//  yahms
//

import Foundation
import Combine

enum HostStorageError: Error {
    case hostWithSameURL
    case wrapped(Error)
    case hostNotFound
    case hostsCouldNotBeStored
    case hostsCouldNotBeRead(Error)
}

protocol HostStorage: AnyObject {
    func hosts() -> AnyPublisher<[Host], HostStorageError>
    func add(_ host: Host) -> AnyPublisher<Bool, HostStorageError>
    func update(hostWithId: String, to updatedHost: Host) -> AnyPublisher<Bool, HostStorageError>
    func delete(_ host: Host) -> AnyPublisher<Bool, HostStorageError>
    var lastSelectedHostId: String? { get set }
}
