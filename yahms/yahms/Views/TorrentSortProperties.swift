//
//  TorrentSortProperties.swift
//  yahms
//

import Foundation

enum TorrentSortProperties {
    enum Direction: String {
        case descending = "descending"
        case ascending = "ascending"
        
        var iconName: String {
            switch self {
            case .descending:
                return "chevron.down"
            case .ascending:
                return "chevron.up"
            }
        }
        
        mutating func toggling() -> Direction {
            switch self {
            case .descending:
                return .ascending
            case .ascending:
                return .descending
            }
        }
    }

    enum InfoCategory: String, Identifiable, CaseIterable {
        case name = "name"
        case size = "size"
        case dateAdded = "date_added"
        
        var title: String {
            switch self {
            case .name:
                return NSLocalizedString("sort_property_name", comment: "")
            case .size:
                return NSLocalizedString("sort_property_size", comment: "")
            case .dateAdded:
                return NSLocalizedString("sort_property_date_added", comment: "")
            }
        }
        
        var id: String {
            return self.rawValue
        }
        
        func sort(_ lvm: TorrentInfoRowViewModel, _ rvm: TorrentInfoRowViewModel) -> Bool {
            switch self {
            case .name:
                return lvm.name < rvm.name
            case .size:
                return lvm.size < rvm.size
            case .dateAdded:
                return lvm.dateAdded < rvm.dateAdded
            }
        }
    }
    
    enum ContentCategory: String, Identifiable, CaseIterable {
        case name = "name"
        case size = "size"
        case priority = "priority"
        
        var title: String {
            switch self {
            case .name:
                return NSLocalizedString("sort_property_name", comment: "")
            case .size:
                return NSLocalizedString("sort_property_size", comment: "")
            case .priority:
                return NSLocalizedString("sort_property_priority", comment: "")
            }
        }
        
        var id: String {
            return self.rawValue
        }
        
        func sort(_ lvm: TorrentContentRowViewModel, _ rvm: TorrentContentRowViewModel) -> Bool {
            switch self {
            case .name:
                return lvm.name < rvm.name
            case .size:
                return lvm.size < rvm.size
            case .priority:
                return lvm.priority < rvm.priority
            }
        }
    }
}
