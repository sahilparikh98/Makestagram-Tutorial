//
//  PostTableViewCell.swift
//  Makestagram
//
//  Created by Apple on 7/19/16.
//  Copyright © 2016 Make School. All rights reserved.
//

import UIKit
import Bond
import Parse

class PostTableViewCell: UITableViewCell {
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var likesIconImageView: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    var postDisposable: DisposableType?
    var likeDisposable: DisposableType?
    
    var post: Post? {
        didSet {
            // 1
            postDisposable?.dispose()
            likeDisposable?.dispose()
            
            if let post = post {
                // 2
                postDisposable = post.image.bindTo(postImageView.bnd_image)
                likeDisposable = post.likes.observe { (value: [PFUser]?) -> () in
                    // 3
                    if let value = value {
                        // 4
                        self.likesLabel.text = self.stringFromUserList(value)
                        print(self.likesLabel.hidden)
                        print("\(self.likesLabel.text!)")
                        // 5
                        self.likeButton.selected = value.contains(PFUser.currentUser()!)
                        // 6
                        self.likesIconImageView.hidden = (value.count == 0)
                    } else {
                        // 7
                        self.likesLabel.text = ""
                        self.likeButton.selected = false
                        self.likesIconImageView.hidden = true
                    }
                }
            }
        }
    }
    
    func stringFromUserList(userList: [PFUser]) -> String
    {
        let usernameList = userList.map{user in user.username!}
        let commaSeperatedUserList = usernameList.joinWithSeparator(",")
        return commaSeperatedUserList
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func moreButtonTapped(sender: AnyObject)
    {
        
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject)
    {
        post?.toggleLikePost(PFUser.currentUser()!)
    }

}
