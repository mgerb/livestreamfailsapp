//
//  storage.service.swift
//  haiku
//
//  Created by Mitchell Gerber on 10/3/18.
//  Copyright © 2018 Mitchell Gerber. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class StorageService {
    static let shared = StorageService()
    private lazy var realm = try? Realm()
    private lazy var fileManager = FileManager.default
    private var documentDirectory: URL?
    
    
    init() {
        guard let directory = try? self.fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        guard let newDir = directory.appendingPathComponent("lsfdata") else {
            return
        }

        self.createDirIfNotExists(dir: newDir)
        self.documentDirectory = newDir
    }
    
    private func createDirIfNotExists(dir: URL) {
        var isDirectory = ObjCBool(true)
        let exists = self.fileManager.fileExists(atPath: dir.absoluteString, isDirectory: &isDirectory)
        
        if !exists && !isDirectory.boolValue {
            try? self.fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
        }
    }
}

// disk cache
extension StorageService {
    private func diskCacheData(data: Data, id: String) {
        DispatchQueue.global().async {
            do {
                let filePath = self.documentDirectory?.appendingPathComponent(id)
                try data.write(to: filePath!)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getDiskCacheData(id: String, closure: @escaping (_ data: Data?) -> Void) {
        let group = DispatchGroup()
        var data: Data?
        group.enter()
        
        DispatchQueue.global().async {
            if let filePath = self.documentDirectory?.appendingPathComponent(id) {
                data = try? Data(contentsOf: filePath)
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            closure(data)
        }
    }
    
    func cacheVideo(data: Data, id: String) {
        self.diskCacheData(data: data, id: "video:\(id)".toBase64())
    }
    
    func cacheImage(data: Data, id: String) {
        self.diskCacheData(data: data, id: "image:\(id)".toBase64())
    }
    
    func getCachedVideo(id: String, closure: @escaping (_ data: Data?) -> Void) {
        self.getDiskCacheData(id: "video:\(id)".toBase64()) { closure($0) }
    }
    
    func getCachedImage(id: String, closure: @escaping (_ data: Data?) -> Void) {
        self.getDiskCacheData(id: "image:\(id)".toBase64()) { closure($0) }
    }

    // TODO:
    func clearDiskCache() {
//        try? self.diskStorage!.removeAll()
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
                .sorted(by: {$0.dateAdded?.compare($1.dateAdded ?? Date()) == .orderedDescending})
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
