//
//  Comment.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/17.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import Foundation
import Firebase

class Comment
{
    var uid: String!
    var commentText: String!
    var creationData: Date!
    var user:User?

    init(user: User, dictionary: Dictionary<String, AnyObject>)
    {
        self.user = user;
        
        if let uid = dictionary["uid"] as? String
        {
            self.uid = uid;
        }
        
        if let commentText = dictionary["commentText"] as? String
        {
            self.commentText = commentText;
        }
        
        if let creationDate = dictionary["creationDate"] as? Double
        {
            self.creationData = Date(timeIntervalSince1970: creationDate);
        }
    }
    
}
