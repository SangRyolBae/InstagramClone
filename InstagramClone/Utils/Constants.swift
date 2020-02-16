//
//  Constants.swift
//  InstagramClone
//
//  Created by 배상렬 on 10/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import Firebase

// MARK: - Root References
let DB_REF = Database.database().reference();
let STORAGE_REF = Storage.storage().reference();

// MARK: - Database References

let USER_REF = DB_REF.child("users");

let USER_FOLLOWER_REF = DB_REF.child("user-followers");
let USER_FOLLOWING_REF = DB_REF.child("user-following");

let POSTS_REF = DB_REF.child("posts");
let USER_POSTS_REF = DB_REF.child("user-posts");

let USER_FEED_REF = DB_REF.child("user-feed");

let USER_LIKES_REF = DB_REF.child("user-likes");
let POST_LIKES_REF = DB_REF.child("post-likes");
