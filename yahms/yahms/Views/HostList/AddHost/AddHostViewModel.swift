//
//  AddHostViewModel.swift
//  yahms
//

import Foundation
import SwiftUI

class AddHostViewModel: ObservableObject {
    enum URLScheme: String, CaseIterable, Identifiable {
        case http
        case https
        
        var id: String {
            return self.rawValue
        }
    }
    
    @Published var isAddLoading = false
    var isAddValid: Bool {
        let authValid = !isAuthenticationEnabled || (!username.isEmpty && !password.isEmpty)
        return !server.isEmpty && authValid
    }
    
    @Published var selectedScheme: URLScheme = .http
    @Published var name = ""
    @Published var server = ""
    let defaultPort = 24560
    @Published var rawPort: String = ""
    var port: Int? {
        get {
            return Int(rawPort)
        }
        set {
            guard let value = newValue else { return }
            rawPort = "\(value)"
        }
    }
    @Published var icon = Host.Icon.laptop
    @Published var username = ""
    @Published var password = ""
    @Published var isAuthenticationEnabled = true
}
