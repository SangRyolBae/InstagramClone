//
//  Message.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/19.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import Foundation
import Firebase

class Message
{
    var messageText:String!
    var fromId: String!
    var toId: String!
    var creationDate: Date!
    
    init(dictionary: Dictionary<String, AnyObject>)
    {
        if let messageText = dictionary["messageText"] as? String
        {
            self.messageText = messageText;
        }
        
        if let fromId = dictionary["fromId"] as? String
        {
            self.fromId = fromId;
        }
        
        if let toId = dictionary["toId"] as? String
        {
            self.toId = toId;
        }
        
        if let creationDate = dictionary["creationDate"] as? Double
        {
            self.creationDate = Date(timeIntervalSince1970: creationDate);
        }
        
    }
    
    func getChatPartnerId() -> String
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return ""};
        
        if fromId == currentUid
        {
            return toId;
        }else
        {
            return fromId;
        }
    }
    
}
