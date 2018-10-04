//
//  storage.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/3/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import Cache

class StorageService {
    static let shared = StorageService()
    
    private let videoDiskConfig = DiskConfig(name: "videoData")
    private let videoMemoryConfig = MemoryConfig(expiry: .never, countLimit: 10, totalCostLimit: 10)
    lazy private var videoStorage: Storage<Data>? = try? Storage(
        diskConfig: self.videoDiskConfig,
        memoryConfig: self.videoMemoryConfig,
        transformer: TransformerFactory.forCodable(ofType: Data.self)
    )

    func cacheVideoData(data: Data, id: String) {
        try? self.videoStorage!.setObject(data, forKey: id)
    }
    
    func getCachedVideo(id: String) -> Data? {
        return try? self.videoStorage!.object(forKey: id)
    }
}
