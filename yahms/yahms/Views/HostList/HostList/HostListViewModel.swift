//
//  HostListViewModel.swift
//  yahms
//

import Foundation

class HostListViewModel: ObservableObject {
    @Published var hosts = [HostRowViewModel]()
    @Published var isLoading = false
    @Published var selection: HostRowViewModel.ID? = nil
    @Published var lastSelectedHostId: HostRowViewModel.ID? = nil
    
    var selectedHostName: String? {
        return selectedHost?.name
    }
    
    var selectedHost: Host? {
        guard let selectedID = selection else { return nil }
        return hosts.first { rowViewModel in
            return rowViewModel.id == selectedID
        }?.host
    }
}
