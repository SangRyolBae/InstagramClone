//
//  User.swift
//  InstagramClone
//
//  Created by 배상렬 on 10/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//
import Firebase

class User
{
    // attributes
    var username: String!;
    var name: String!;
    var profileImageUrl: String!;
    var uid: String!;
    var isFollowed = false;
    
    init(uid: String, dictionary: Dictionary<String, AnyObject>)
    {
        self.uid = uid;
        
        if let username = dictionary["username"] as? String {
            self.username = username;
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name;
        }
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl;
        }
    }
    
    
    func follow()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        guard let uid = uid else { return };
        
        // set is followed to true
        self.isFollowed = true;
        
        // add followed user to current user-following structure
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid:1]);
        
        // add current user to followed user-follower structure
        USER_FOLLOWER_REF.child(uid).updateChildValues([currentUid:1]);
        
        // upload follow notification to server
        self.uploadFollowNotificationToServer();
        
        // add followed users posts to current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key;
            USER_FEED_REF.child(currentUid).updateChildValues([postId: 1]);
        }
    }
    
    
    func unfollow()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        
        guard let uid = uid else { return };
        
        // set is followed to false
        self.isFollowed = false;
        
        // remove user from current user-following structure
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue();
        
        // remove current user from user-follower structure
        USER_FOLLOWER_REF.child(uid).child(currentUid).removeValue();
               
        //remove unfollowed users posts from current user-feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key;
            
            USER_FEED_REF.child(currentUid).child(postId).removeValue();
        }
    }
    
    func checkIfUserIsFollowed(completion: @escaping(Bool) ->())
    {
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        
        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(self.uid)
            {
                
                self.isFollowed = true;
                completion(true);
                
            }else
            {
                self.isFollowed = false;
                completion(false);
            }
            
        }
    }
    
    func uploadFollowNotificationToServer()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        guard let uid = self.uid else {return};
        let creationDate = Int(NSDate().timeIntervalSince1970);
       
        // notification values
        let values = [ "checked" : 0,
                      "creationDate" : creationDate,
                      "uid" : currentUid,
                      "type" : FOLLOW_INT_VALUE
                    ] as [String: AnyObject];
       
       NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values);
    }
}

