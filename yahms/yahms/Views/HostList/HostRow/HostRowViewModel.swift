//
//  HostRowViewModel.swift
//  yahms
//

import Foundation
import SwiftUI

struct HostRowViewModel: Hashable, Identifiable {
    private(set) var host: Host
    
    var name: String {
        return host.name
    }
    
    var address: String {
        return host.url.absoluteString
    }
    
    var icon: Host.Icon {
        return host.icon
    }
    
    var id: String {
        return address
    }
    
    init(host: Host) {
        self.host = host
    }
}
