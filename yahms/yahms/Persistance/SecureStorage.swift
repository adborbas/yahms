//
//  SecureStorage.swift
//  yahms
//

import Foundation

protocol SecureStorage {
    func getData(for: String) -> Data?
    func setData(_ data: Data, for key: String) -> Bool
}
