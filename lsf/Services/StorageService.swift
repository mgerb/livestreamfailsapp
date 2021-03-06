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
import Disk

class StorageService {
    static let shared = StorageService()
    private var realm: Realm?
}

// disk cache
extension StorageService {
    private func diskCacheData(data: Data, id: String) {
        try? Disk.save(data, to: .caches, as: "lsfcache/\(id)");
    }
    
    private func getDiskCacheData(id: String, closure: @escaping (_ data: Data?) -> Void) {
        let data = try? Disk.retrieve("lsfcache/\(id)", from: .caches, as: Data.self)
        closure(data)
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

    /// get string in MB
    func getDocumentDirecorySize() -> String {
        
        guard let directory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return "0 mb"
        }
        
        let cacheDir = directory.appendingPathComponent("lsfcache")
        
        if let documentsDirectoryURL = cacheDir  {
            if (try? documentsDirectoryURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
                var folderSize = 0
                (FileManager.default.enumerator(at: documentsDirectoryURL, includingPropertiesForKeys: nil)?.allObjects as? [URL])?.lazy.forEach {
                    folderSize += (try? $0.resourceValues(forKeys: [.totalFileAllocatedSizeKey]))?.totalFileAllocatedSize ?? 0
                }
                return (folderSize / 1_000_000).commaRepresentation + " mb"
            }
        }
        
        return "0 mb"
    }
    
    func clearDocumentDirectoryCache() {
        do {
           try Disk.remove("lsfcache", from: .caches)
        } catch {
            print(error)
        }
    }
}

// UserDefaults stuff
extension StorageService {
    
    func clearHiddenPosts() {
        UserDefaults.standard.removeObject(forKey: "hiddenPosts")
    }
    
    /// store hidden posts
    func storeHiddenPost(redditLink: RedditLink) {
        var hiddenPosts: [String: Any]
        hiddenPosts = UserDefaults.standard.dictionary(forKey: "hiddenPosts") ?? [:]
        hiddenPosts[redditLink.id] = true
        UserDefaults.standard.set(hiddenPosts, forKey: "hiddenPosts")
    }
    
    /// check if post has been hidden by user
    func getHiddenPost(redditLink: RedditLink) -> Bool {
        let hiddenPosts = UserDefaults.standard.dictionary(forKey: "hiddenPosts") ?? [:]
        return (hiddenPosts[redditLink.id] as? Bool) == true
    }

    /// store reddit link ID if user has watched it
    func storeWatchedRedditLink(redditLink: RedditLink) {
        UserDefaults.standard.set(true, forKey: "wrl:\(redditLink.id)")
    }
    
    /// check if user has watched reddit link by ID
    func getWatchedRedditLink(redditLink: RedditLink) -> Bool {
        return UserDefaults.standard.bool(forKey: "wrl:\(redditLink.id)")
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
    
    func storeRedditUserAuthentication(auth: RedditAuthentication) {
        if let encoded = try? JSONEncoder().encode(auth) {
            UserDefaults.standard.set(encoded, forKey: "redditUserAuthentication")
        }
    }
    
    func getRedditUserAuthentication() -> RedditAuthentication? {
        let authString = UserDefaults.standard.data(forKey: "redditUserAuthentication")
        if let authString = authString {
            return try? JSONDecoder().decode(RedditAuthentication.self, from: authString)
        }
        return nil
    }
    
    func clearRedditUserAuthentication() {
        UserDefaults.standard.removeObject(forKey: "redditUserAuthentication")
    }
}

// realm reddit storage
extension StorageService {
    
    func realmMigrations() {
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
        
        self.realm = try? Realm()
    }
    
    func storeRedditLinkFavorite(redditLink: RedditLink) {
        let realmRedditLink = RealmRedditLink(redditLink)
        try? self.realm?.write {
            self.realm?.add(realmRedditLink, update: true)
        }
    }
    
    func deleteRedditLinkFavorite(id: String) {
        if let link = self.getRedditLinkFavorite(id: id) {
            try? self.realm?.write {
                self.realm?.delete(link)
            }
        }
    }
    
    // get reddit link favorites from storage - order by date added
    func getRedditLinkFavorites() -> [RedditLink] {
        if let links = self.realm?.objects(RealmRedditLink.self) {
            return links
                .map { $0.getRedditLink() }
                .sorted(by: {$0.dateAdded?.compare($1.dateAdded ?? Date()) == .orderedDescending})
        }
        return []
    }
    
    func getRedditLinkFavorite(id: String) -> RealmRedditLink? {
        return self.realm?.object(ofType: RealmRedditLink.self, forPrimaryKey: id)
    }
    
    func redditLinkFavoriteExists(id: String) -> Bool {
        return self.realm?.object(ofType: RealmRedditLink.self, forPrimaryKey: id) != nil
    }
}
