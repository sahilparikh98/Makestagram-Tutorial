//
//  ParseHelper.swift
//  Makestagram
//
//  Created by Apple on 7/19/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse

class ParseHelper {
    
    static let ParseFollowClass       = "Follow"
    static let ParseFollowFromUser    = "fromUser"
    static let ParseFollowToUser      = "toUser"
    
    // Like Relation
    static let ParseLikeClass         = "Like"
    static let ParseLikeToPost        = "toPost"
    static let ParseLikeFromUser      = "fromUser"
    
    // Post Relation
    static let ParsePostUser          = "user"
    static let ParsePostCreatedAt     = "createdAt"
    
    // Flagged Content Relation
    static let ParseFlaggedContentClass    = "FlaggedContent"
    static let ParseFlaggedContentFromUser = "fromUser"
    static let ParseFlaggedContentToPost   = "toPost"
    
    // User Relation
    static let ParseUserUsername      = "username"
    
    
    static func timelineRequestForCurrentUser(range: Range<Int>, completionBlock: PFQueryArrayResultBlock) {
        let followingQuery = PFQuery(className: ParseFollowClass)
        followingQuery.whereKey(ParseFollowFromUser, equalTo:PFUser.currentUser()!)
        
        let postsFromFollowedUsers = Post.query()
        postsFromFollowedUsers!.whereKey(ParsePostUser, matchesKey: ParseFollowToUser, inQuery: followingQuery)
        
        let postsFromThisUser = Post.query()
        postsFromThisUser!.whereKey(ParsePostUser, equalTo: PFUser.currentUser()!)
        
        let query = PFQuery.orQueryWithSubqueries([postsFromFollowedUsers!, postsFromThisUser!])
        query.includeKey(ParsePostUser)
        query.orderByDescending(ParsePostCreatedAt)
        
        // 2
        query.skip = range.startIndex
        // 3
        query.limit = range.endIndex - range.startIndex
        
        query.findObjectsInBackgroundWithBlock(completionBlock)
    }
    //MARK: Likes
    
    static func likePost(user: PFUser, post: Post)
    {
        let likeObject = PFObject(className: "Like")
        likeObject[ParseLikeFromUser] = user
        likeObject[ParseLikeToPost] = post
        likeObject.saveInBackgroundWithBlock(nil)
    }
    
    static func unlikePost(user: PFUser, post: Post)
    {
        let postQuery = PFQuery(className: ParseLikeClass)
        postQuery.whereKey(ParseLikeFromUser, equalTo: user)
        postQuery.whereKey(ParseLikeToPost, equalTo: post)
        
        postQuery.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            // 2
            if let results = results {
                for like in results {
                    like.deleteInBackgroundWithBlock(nil)
                }
            }
        }
    }
    
    static func likesForPost(post: Post, completionBlock: PFQueryArrayResultBlock) {
        
        let query = PFQuery(className: ParseLikeClass)
        query.whereKey(ParseLikeToPost, equalTo: post)
        query.includeKey(ParseLikeFromUser)
        query.findObjectsInBackgroundWithBlock(completionBlock)
        
    }
    
    
    
    
}

extension PFObject {
    
    public override func isEqual(object: AnyObject?) -> Bool {
        if (object as? PFObject)?.objectId == self.objectId {
            return true
        } else {
            return super.isEqual(object)
        }
    }
    
}

