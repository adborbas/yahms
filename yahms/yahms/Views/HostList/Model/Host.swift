//
//  Host.swift
//  yahms
//

import Foundation

struct Host: Hashable, Codable {
    let id: String
    let name: String
    let url: URL
    let icon: Icon
    let authentication: Authentication
}

extension Host {
    enum Authentication: Hashable, Codable {
        case bypassed
        case basicAuth(BasicAuthCredentials)
    }
}

extension Host {
    struct BasicAuthCredentials: Hashable, Codable {
        let username: String
        let password: String
    }
}

extension Host {
    enum Icon: String, CaseIterable, Identifiable, Equatable, Codable {
        case desktop = "desktopcomputer"
        case server = "server.rack"
        case laptop = "laptopcomputer"
        case portable = "mediastick"
        case tv = "tv"
        case service = "network"
        case externalDrive = "externaldrive.connected.to.line.below"
        
        var id: String {
            return rawValue
        }
    }
}
