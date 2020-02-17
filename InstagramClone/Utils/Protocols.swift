//
//  Protocols.swift
//  InstagramClone
//
//  Created by 배상렬 on 10/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

protocol UserProfileHeaderDelegate
{
    func handleEditFollowTapped(for header: UserProfileHeader);
    func setUserStats(for header: UserProfileHeader);
    func handleFollowersTapped(for header: UserProfileHeader);
    func handleFollowingTapped(for header: UserProfileHeader);
}

protocol FollowCellDelegate
{
    
    func handleFollowTapped(for cell:FollowLikeCell);
    
}

protocol FeedCellDelegate
{
    func handleUsernameTapped(for cell:FeedCell);
    func handleOptionTapped(for cell:FeedCell);
    func handleLikeTapped(for cell:FeedCell, isDoubleTap: Bool);
    func handleCommentTapped(for cell:FeedCell);
    func handleConfigureLikeButton(for cell:FeedCell);
    func handleShowLikes(for cell:FeedCell);
}

protocol Printable
{
    var description: String { get }
       
}
