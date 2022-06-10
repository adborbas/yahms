//
//  TorrentContentDirectory.swift
//  yahms
//

import Foundation

typealias TorrentDirectoryPath = Queue<String>

class TorrentContentDirectory: TorrentContentNode {
    static let rootDirectoryName = NSLocalizedString("torrent_content_root_dir_name", comment: "")
    weak var parent: TorrentContentDirectory?
    var children = [TorrentContentNode]()
    
    private var subDirs: [TorrentContentDirectory] {
        return children.compactMap { $0 as? TorrentContentDirectory }
    }
    
    private var subFiles: [TorrentContentFile] {
        return children.compactMap { $0 as? TorrentContentFile }
    }
    
    private var allRecursiveFiles: [TorrentContentFile] {
        var files = [TorrentContentFile]()
        files.append(contentsOf: subFiles)
        subDirs.forEach { files.append(contentsOf: $0.allRecursiveFiles) }
        return files
    }

    private let nodeName: String
    var name: String { nodeName }
    
    var index: Set<Int> {
        return Set<Int>(allRecursiveFiles.map { $0.index.first! })
    }
    
    lazy var size: Int64 = {
        let childrenSize = allRecursiveFiles.reduce(0) { partialResult, file in
            return partialResult + file.size
        }
        return childrenSize
    }()

    private lazy var downloaded: Int64 = {
        let childrenDownloaded = allRecursiveFiles.reduce(0) { partialResult, file in
            return partialResult + Int64(Double(file.size) * Double(file.progress))
        }
        return childrenDownloaded
    }()

    lazy var progress: Float = {
        return (Float(downloaded) / Float(size))
    }()

    lazy var priority: TorrentContentPriority = {
        guard let firstChildPriority = children.first?.priority else { return .mixed }
        if children.allSatisfy({ $0.priority == firstChildPriority }) {
            return firstChildPriority
        }

        return .mixed
    }()

    init(name: String) {
        self.nodeName = name
    }

    func addChild(_ node: TorrentContentNode) {
        children.append(node)
        node.parent = self
    }
    
    func childDirectory(named: String) -> TorrentContentDirectory? {
        return subDirs.first { $0.name == named }
    }
    
    func findDirectory(onPath path: TorrentDirectoryPath) -> TorrentContentDirectory? {
        var mutatingPath = path
        guard let current = mutatingPath.dequeue(),
              current == name else { return nil }
        
        if mutatingPath.isEmpty { return self }
    
        guard let nextPathComponent = mutatingPath.peek,
              let childDir = childDirectory(named: nextPathComponent) else { return nil }
        
        return childDir.findDirectory(onPath: mutatingPath)
    }
}
