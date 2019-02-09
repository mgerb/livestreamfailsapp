//
//  storage.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/3/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import Cache
import Realm
import RealmSwift

class StorageService {
    static let shared = StorageService()
    
    private lazy var realm = try? Realm()

    private let diskConfig = DiskConfig(name: "diskData")
    private let memoryConfig = MemoryConfig(expiry: .never, countLimit: 5, totalCostLimit: 10)
    lazy private var diskStorage: Storage<Data>? = try? Storage(
        diskConfig: self.diskConfig,
        memoryConfig: self.memoryConfig,
        transformer: TransformerFactory.forCodable(ofType: Data.self)
    )

}

/// data storage with Cache
extension StorageService {
    private func diskCacheData(data: Data, id: String) {
        self.diskStorage!.async.setObject(data, forKey: id) { $0 }
    }
    
    private func getDiskCacheData(id: String, closure: @escaping (_ data: Data?) -> Void) {
        self.diskStorage!.async.object(forKey: id) { result in
            switch result {
            case .value(let val):
                closure(val)
            case .error(let err):
                closure(nil)
            }
        }
    }
    
    func cacheVideo(data: Data, id: String) {
        self.diskCacheData(data: data, id: "video:\(id)")
    }
    
    func cacheImage(data: Data, id: String) {
        self.diskCacheData(data: data, id: "image:\(id)")
    }
    
    func getCachedVideo(id: String, closure: @escaping (_ data: Data?) -> Void) {
        self.getDiskCacheData(id: "video:\(id)") { closure($0) }
    }
    
    func getCachedImage(id: String, closure: @escaping (_ data: Data?) -> Void) {
        self.getDiskCacheData(id: "image:\(id)") { closure($0) }
    }

    func clearDiskCache() {
        try? self.diskStorage!.removeAll()
    }
}

// UserDefaults stuff
extension StorageService {
    /// store reddit post ID if user has watched it
    func storeWatchedRedditPost(redditPost: RedditPost) {
        UserDefaults.standard.set(true, forKey: "wrp:\(redditPost.id)")
    }
    
    /// check if user has watched reddit post by ID
    func getWatchedRedditPost(redditPost: RedditPost) -> Bool {
        return UserDefaults.standard.bool(forKey: "wrp:\(redditPost.id)")
    }
    
    func storeRedditAuthentication(auth: RedditAuthentication) {
        if let encoded = try? JSONEncoder().encode(auth) {
            UserDefaults.standard.set(encoded, forKey: "redditAuthentication")
        }
    }
    
    func getRedditAuthentication() -> RedditAuthentication? {
        let authString = UserDefaults.standard.data(forKey: "redditAuthentication")
        if let authString = authString {
            return try? JSONDecoder().decode(RedditAuthentication.self, from: authString)
        }
        return nil
    }
}

// realm reddit storage
extension StorageService {
    
    func storeRedditPostFavorite(redditPost: RedditPost) {
        let realmRedditPost = RealmRedditPost(redditPost)
        try? self.realm?.write {
            self.realm?.add(realmRedditPost, update: true)
        }
    }
    
    func deleteRedditPostFavorite(id: String) {
        if let post = self.getRedditPostFavorite(id: id) {
            try? self.realm?.write {
                self.realm?.delete(post)
            }
        }
    }
    
    // get reddit post favorites from storage - order by date added
    func getRedditPostFavorites() -> [RedditPost] {
        if let posts = self.realm?.objects(RealmRedditPost.self) {
            return posts
                .map { $0.getRedditPost() }
                .sorted(by: {$0.dateAdded!.compare($1.dateAdded!) == .orderedDescending})
        }
        return []
    }
    
    func getRedditPostFavorite(id: String) -> RealmRedditPost? {
        return self.realm?.object(ofType: RealmRedditPost.self, forPrimaryKey: id)
    }
    
    func redditPostFavoriteExists(id: String) -> Bool {
        return self.realm?.object(ofType: RealmRedditPost.self, forPrimaryKey: id) != nil
    }
}
