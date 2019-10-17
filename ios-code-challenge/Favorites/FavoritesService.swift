//
//  FavoritesService.swift
//  ios-code-challenge
//
//  Created by Ryan Novak on 2019-10-11.
//  Copyright © 2019 Dustin Lange. All rights reserved.
//

import Foundation

//There are lots of ways one could implement a service, and I'm not particularly attached to any of them in Swift. I chose to do a singleton here because we already have one singleton service in this project (AFYelpAPIClient) and that generally seems to be the standard for that sort of thing within Apple frameworks. I'll generally follow whatever the standard is for a given project.
class FavoriteService {
    private init() {
        if let url = FavoriteService.getFileUrl(),
            let storedFavorites = try? String.init(contentsOfFile: url.path, encoding: .utf8) {
            let favoriteIds = storedFavorites.components(separatedBy: ",")
            //This will help us preserve order
            var tempFavorites: [YLPBusiness?] = favoriteIds.map { _ in nil }
            let dispatch = DispatchGroup()
            
            for (index, favorite) in favoriteIds.enumerated() {
                dispatch.enter()
                AFYelpAPIClient.shared()?.getBusiness(id: favorite, completionHandler: {
                    business, _  in
                    tempFavorites[index] = business
                    dispatch.leave()
                })
            }
            
            dispatch.notify(queue: .main) {
                self._favorites = tempFavorites.filter { $0 != nil } as! [YLPBusiness]
                self.initialized = true
                self.watchers.forEach { $0() }
                self.watchers.removeAll()
            }
        }
        else {
            initialized = true
        }
    }
    static let shared = FavoriteService()
    
    private var _favorites: [YLPBusiness] = []
    var favorites: [YLPBusiness] {
        get {
            return _favorites
        }
    }
    
    /* Sorry of the novel of a comment here, but I should explain this. This is a bad way of doing this.
     * I don't like requiring every consumer of this service to interact with it through closures.
     * The problem this is trying to solve is that the shard instance isn't getting initialized until
     * it's being used (not sure if there is a swift feature to make it initialize when the application
     * loads, but google seems to be unhelpful in finding the answer to that), and since it takes some time
     * to make the calls, the consumers of the service get the array of favorites before we've added the
     * stuff we've loaded from Yelp. There are multiple ways I might solve this in a normal context, but
     * those are either complex to the point that I feel they are out of scope of this application. The way
     * I would generally solve this is by using observables. I didn't, however, want to bring in an
     * observable library to use in a single place though. Under normal circumstances, I would rarely add
     * another dependency if I were only going to use it once for a simple task.
     * The second way I would solve this normally is just call shared in
     * application:didFinishLaunchingWithOptions:. This would initialize the class imediately on
     * application launch and the calls to Yelp would return before anything tried to access the favorites
     * (assuming, of course, you're not on a slow network). I decided not to do that because one of my goals
     * is to be as non-destructive as possible. While I might be allowed to convert it to Swift in the actual
     * codebase, that codebase is mixed Swift and Objective-C, so my work here should demonstrate I can work
     * with both.
     * With all that in mind, while this isn't my favorite way to do this, it works.
     */
    var initialized = false
    var watchers: [() -> ()] = []
    func runWhenInitialized(_ watcher: @escaping () -> ()) {
        if initialized {
            watcher()
        }
        else {
            watchers.append(watcher)
        }
    }
    
    func add(_ business: YLPBusiness) {
        if favorites.first(where: { $0.identifier == business.identifier }) == nil {
            _favorites.append(business)
            
            //I don't have an ideal resolution for errors here, so we're going to just ignore errors. If this were a real app, we would probably want to notify the user something failed
            if let url = FavoriteService.getFileUrl() {
                try? _favorites.map { $0.identifier }.joined(separator: ",").write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    func remove(_ business: YLPBusiness) {
        if let index = favorites.firstIndex(where: { $0.identifier == business.identifier }) {
            _favorites.remove(at: index)
            
            if let url = FavoriteService.getFileUrl() {
                try? _favorites.map { $0.identifier }.joined(separator: ",").write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }
    
    func isFavorite(_ business: YLPBusiness) -> Bool {
        return favorites.first { $0.identifier == business.identifier } != nil
    }
    
    static func getFileUrl() -> URL? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        return url?.appendingPathComponent("favorites")
    }
}
