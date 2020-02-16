//
//  Extensions.swift
//  InstagramClone
//
//  Created by 배상렬 on 06/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

extension UIView
{
    func anchor(top : NSLayoutYAxisAnchor?, left : NSLayoutXAxisAnchor?, bottom : NSLayoutYAxisAnchor?, right : NSLayoutXAxisAnchor?,
                paddingTop : CGFloat, paddingLeft : CGFloat, paddingBottom : CGFloat, paddingRight : CGFloat,
                width : CGFloat, height : CGFloat)
    {
        translatesAutoresizingMaskIntoConstraints = false;
        
        if let top = top
        {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true;
        }
        
        if let left = left
        {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true;
        }
        
        if let bottom = bottom
        {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true;
        }
        
        if let right = right
        {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true;
        }
        
        if width != 0
        {
            widthAnchor.constraint(equalToConstant: width).isActive = true;
        }
        
        if height != 0
        {
            heightAnchor.constraint(equalToConstant: height).isActive = true;
        }
    }
        
}

extension Database
{
    static func fetchUser(with uid: String, completion: @escaping(User) -> ())
    {
        USER_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let userDict = snapshot.value as? Dictionary<String, AnyObject> else {return};
            
            let user = User(uid: uid, dictionary: userDict);
            
            completion(user);
        }
    }
    
    static func fetchPost(with postId: String, completion: @escaping(Post) -> ())
    {
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return};
            guard let ownerUid = dictionary["ownerUid"] as? String else {return};
            
            Database.fetchUser(with: ownerUid) { (user) in
                
                let post = Post(postId: postId, user:user, dictionary: dictionary);
                           
                completion(post);
                
            }
        }
    }
}
