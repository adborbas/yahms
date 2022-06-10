//
//  SettingsStorage.swift
//  yahms
//

import Foundation
import SwiftUI

protocol SettingsStorage: AnyObject {
    var torrentListSortCategoryId: TorrentSortProperties.InfoCategory.ID { get set }
    var torrentListSortDirection: TorrentSortProperties.Direction { get set }
    
    var torrentContentSortCategoryId: TorrentSortProperties.ContentCategory.ID { get set }
    var torrentContentSortDirection: TorrentSortProperties.Direction { get set }
    
    var hosts: [Host] { get set }
}

class UserDefaultsSettingsStorage: SettingsStorage {
    @AppStorage("torrent_list_sort_category_id")
    var torrentListSortCategoryId: TorrentSortProperties.InfoCategory.ID = TorrentSortProperties.InfoCategory.name.id
    
    @AppStorage("torrent_list_sort_direction")
    var torrentListSortDirection: TorrentSortProperties.Direction = .ascending
    
    @AppStorage("torrent_content_sort_category_id")
    var torrentContentSortCategoryId: TorrentSortProperties.ContentCategory.ID = TorrentSortProperties.ContentCategory.name.id
    
    @AppStorage("torrent_content_sort_direction")
    var torrentContentSortDirection: TorrentSortProperties.Direction = .ascending
    
    @AppStorage("hosts")
    var hosts = [Host]()
}
