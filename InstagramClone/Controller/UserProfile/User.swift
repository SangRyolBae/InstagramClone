//
//  User.swift
//  InstagramClone
//
//  Created by 배상렬 on 10/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

class User
{
    // attributes
    var username: String!;
    var name: String!;
    var profileImageUrl: String!;
    var uid: String!;
    
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
}

