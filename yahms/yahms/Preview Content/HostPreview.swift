//
//  HostPreview.swift
//  yahms
//

import Foundation

extension Preview {
    enum HostPreviewData {
        private static func randomIP4Part() -> Int {
            return Int.random(in: 1...255)
        }
        
        static func withIcon(_ icon: Host.Icon) -> HostRowViewModel {
            let host = Host(id: UUID().uuidString,
                            name: icon.rawValue,
                            url: URL(string: "http://102.168.\(randomIP4Part()).\(randomIP4Part())")!,
                            icon: icon,
                            authentication: .bypassed)
            return HostRowViewModel(host: host)
        }
        
        static func allIcons() -> [HostRowViewModel] {
            return Host.Icon.allCases.map { withIcon($0) }
        }
    }
}
