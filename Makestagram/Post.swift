//
//  Post.swift
//  Makestagram
//
//  Created by Apple on 7/18/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import Foundation
import Parse
import Bond

class Post : PFObject, PFSubclassing {
    
    // 2
    @NSManaged var imageFile: PFFile?
    @NSManaged var user: PFUser?
    var image: Observable<UIImage?> = Observable(nil)
    var photoUploadTask: UIBackgroundTaskIdentifier?
    var likes: Observable<[PFUser]?> = Observable(nil)
    
    
    //MARK: PFSubclassing Protocol
    
    // 3
    static func parseClassName() -> String {
        return "Post"
    }
    
    // 4
    override init () {
        super.init()
    }
    
    override class func initialize() {
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            // inform Parse about this subclass
            self.registerSubclass()
        }
    }
    
    func fetchLikes() {
        
        if (likes.value != nil) {
            return
        }
        
        
        ParseHelper.likesForPost(self, completionBlock: { (likes: [PFObject]?, error: NSError?) -> Void in
            
            let validLikes = likes?.filter { like in like[ParseHelper.ParseLikeFromUser] != nil }
            
            self.likes.value = validLikes?.map { like in
                let fromUser = like[ParseHelper.ParseLikeFromUser] as! PFUser
                
                return fromUser
            }
        })
    }
    
    func doesUserLikePost(user: PFUser) -> Bool
    {
        if let likes = likes.value
        {
            return likes.contains(user)
        }
        else
        {
            return false
        }
    }
    
    func toggleLikePost(user: PFUser)
    {
        if(doesUserLikePost(user))
        {
            likes.value = likes.value?.filter{ $0 != user}
            ParseHelper.unlikePost(user, post: self)
            
        }
        else
        {
            likes.value?.append(user)
            ParseHelper.likePost(user, post: self)
        }
    }
    
    func uploadPost() {
        
        if let image = image.value {
            
            guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {return}
            guard let imageFile = PFFile(name: "image.jpg", data: imageData) else {return}
            
            user = PFUser.currentUser()
            self.imageFile = imageFile
            
            photoUploadTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler { () -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
            
            saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoUploadTask!)
            }
        }
    }

    func downloadImage() {
        // if image is not downloaded yet, get it
        // 1
        if (image.value == nil) {
            // 2
            imageFile?.getDataInBackgroundWithBlock { (data: NSData?, error: NSError?) -> Void in
                if let data = data {
                    let image = UIImage(data: data, scale:1.0)!
                    // 3
                    self.image.value = image
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    
}
