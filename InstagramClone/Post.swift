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
                
                // send notification to server
                self.sendLikeNotificationToServer();
                
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
                    
            // observe database for notification id to remove
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                
                // notification id to remove from server
                guard let notificationID = snapshot.value as? String else {return};
               
                // remove notification from server
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationID).removeValue(completionBlock: { (err, ref) in
                                        
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
                    
                });
            }
        }
    }
    
    func sendLikeNotificationToServer()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        guard let postId = self.postId else {return};
        guard let ownerUid = self.ownerUid else {return};
        let creationDate = Int(NSDate().timeIntervalSince1970);
        
        if currentUid != self.ownerUid
        {
            
            // notification values
            let values = [ "checked" : 0,
                           "creationDate" : creationDate,
                           "uid" : currentUid,
                           "type" : LIKE_INT_VALUE,
                           "postId" : postId
                         ] as [String: AnyObject];
            
            // notification database reference
            let notificationRef = NOTIFICATIONS_REF.child(ownerUid).childByAutoId();
            
            // upload notification values to database
            notificationRef.updateChildValues(values) { (err, ref) in
                
                USER_LIKES_REF.child(currentUid).child(postId).setValue(notificationRef.key);
            }
        }
    }
    
    func deletePost()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).child(self.postId).removeValue()
        }
        
        USER_FEED_REF.child(currentUid).child(postId).removeValue()
        
        USER_POSTS_REF.child(currentUid).child(postId).removeValue()
        
        POST_LIKES_REF.child(postId).observe(.childAdded) { (snapshot) in
            let uid = snapshot.key
            
            USER_LIKES_REF.child(uid).child(self.postId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let notificationId = snapshot.value as? String else { return }
                
                NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    
                    POST_LIKES_REF.child(self.postId).removeValue()
                    
                    USER_LIKES_REF.child(uid).child(self.postId).removeValue()
                })
            })
        }
        
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        for var word in words {
            if word.hasPrefix("#") {
                
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                HASHTAG_POST_REF.child(word).child(postId).removeValue()
            }
        }
        
        COMMENT_REF.child(postId).removeValue()
        POSTS_REF.child(postId).removeValue()
    }
}
