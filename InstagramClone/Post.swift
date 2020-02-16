//
//  Post.swift
//  InstagramClone
//
//  Created by 배상렬 on 14/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//
import Foundation
import Firebase

class Post
{
    var caption: String!;
    var likes: Int!;
    var imageUrl: String!;
    var ownerUid: String!;
    var creationDate: Date!;
    var postId: String!;
    var user: User?;
    var didLike = false;
    
    init(postId: String, user:User, dictionary: Dictionary<String, AnyObject>)
    {
        self.postId = postId;
        self.user = user;
        
        if let caption = dictionary["caption"] as? String
        {
            self.caption = caption;
        }
        
        if let likes = dictionary["likes"] as? Int
        {
            self.likes = likes;
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String
        {
            self.imageUrl = imageUrl;
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String
        {
            self.ownerUid = ownerUid;
        }
        
        if let creationDate = dictionary["creationDate"] as? Double
        {
            self.creationDate = Date(timeIntervalSince1970: creationDate);
        }
        
    }
 
    func adjectLikes(addLike: Bool, completion: @escaping(Int) ->() )
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        guard let postId = self.postId else { return};
        
        if addLike
        {
            
            // updates user-likes structure
            USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock:  { (err, ref) in
                
                // updates post-likes structure
                POST_LIKES_REF.child(self.postId).updateChildValues([currentUid: 1], withCompletionBlock:  { (err, ref) in
                    
                    self.likes += 1;
                    self.didLike = true
                    completion(self.likes);
                    
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes);
                    
                    print("This post has \(String(describing: self.likes)) likes");
                    print("Successfully updated like structure in database");
                    
                })
                
            })
                        
        }else
        {
                                   
            // remove like from user-like structure
            USER_LIKES_REF.child(currentUid).child(postId).removeValue(completionBlock: { (err, ref) in
                
                // remove like from post-like structure
                POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { (err, ref) in
                    
                    guard self.likes > 0 else {return};
                    self.likes -= 1;
                    self.didLike = false;
                    completion(self.likes);
                    
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes);
                    
                    print("This post has \(String(describing: self.likes)) likes");
                    print("Successfully removed likes from database");
                }
            });
                        
        }
    }
}
