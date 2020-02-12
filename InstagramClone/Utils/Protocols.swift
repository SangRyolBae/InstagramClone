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
    
    func handleFollowTapped(for cell:FollowCell);
    
}
