//
//  KeychainSwift+SecureStorage.swift
//  yahms
//

import Foundation
import KeychainSwift

extension KeychainSwift: SecureStorage {
    func getData(for key: String) -> Data? {
        return getData(key)
    }
    
    func setData(_ data: Data, for key: String) -> Bool {
        return set(data, forKey: key, withAccess: .accessibleWhenUnlocked)
    }
}
