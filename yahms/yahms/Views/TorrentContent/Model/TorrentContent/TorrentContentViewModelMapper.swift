//
//  TorrentContentViewModelMapper.swift
//  yahms
//

import Foundation
import qBittorrent

protocol TorrentContentViewModelMapper {
    func mapContentsToDirectory(_ contents: [TorrentContent]) -> TorrentContentDirectory
    func mapDirectoryToContentRowViewModels(_ directory: TorrentContentDirectory) -> [TorrentContentRowViewModel]
}

class DefaultTorrentContentViewModelMapper: TorrentContentViewModelMapper {
    func mapContentsToDirectory(_ contents: [TorrentContent]) -> TorrentContentDirectory {
        let root = TorrentContentDirectory(name: TorrentContentDirectory.rootDirectoryName)
        
        for (_, content) in contents.enumerated() {
            let filePaths = content.name.split(separator: "/").map { String($0) }
            guard let fileName = filePaths.last else { continue }
            
            let file = TorrentContentFile(index: content.index,
                                          name: fileName,
                                          size: content.size,
                                          progress: content.progress,
                                          priority: TorrentContentPriority(content.priority))
            
            // Create parent directories
            let parentDirectories = filePaths.dropLast()
            var previousDir = root
            for (_, parentDirectoryName) in parentDirectories.enumerated() {
                if let parentDir = previousDir.childDirectory(named: parentDirectoryName) {
                    previousDir = parentDir
                } else {
                    let parentDir = TorrentContentDirectory(name: parentDirectoryName)
                    previousDir.addChild(parentDir)
                    previousDir = parentDir
                }
            }
            
            previousDir.addChild(file)
            
        }
        
        return root
    }
    
    func mapDirectoryToContentRowViewModels(_ directory: TorrentContentDirectory) -> [TorrentContentRowViewModel] {
        return directory.children.map {
            TorrentContentRowViewModel(index: $0.index,
                                       name: $0.name,
                                       isDirectory: $0 is TorrentContentDirectory,
                                       size: $0.size,
                                       progress: $0.progress,
                                       priority: $0.priority)
        }
    }
}
