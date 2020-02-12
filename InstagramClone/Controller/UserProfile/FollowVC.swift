//
//  FollowVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 11/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase;

private let reuseIdentifer = "FollowCell";

class FollowVC: UITableViewController, FollowCellDelegate
{
    
    
    
    // MARK: - Properties
    var viewFollowers = false;
    var viewFollowing = false;
    var uid: String?;
    var users = [User]();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdentifer);
        
        // configure nav controller
        if viewFollowers
        {
            navigationItem.title = "Followers";
        }else
        {
            navigationItem.title = "Following";
        }

        // clear separator lines
        tableView.separatorColor = .clear;
        
        // fetch users
        fetchUsers();
        
        if let uid = self.uid {
            print("User id is \(uid)");
        }
    }
    
    
    // MARK: - UITableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // 총갯수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! FollowCell;
        
        cell.delegate = self;
        
        cell.user = self.users[indexPath.row];
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let user = users[indexPath.row];
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout());
        
        userProfileVC.user = user;
        
        navigationController?.pushViewController(userProfileVC, animated: true);
    }
    
    
    // MARK: - API
    func fetchUsers()
    {
        guard let uid = self.uid else { return };
        var ref: DatabaseReference!;
        
        if (viewFollowers)
        {
            ref = USER_FOLLOWER_REF;
        }else{
            ref = USER_FOLLOWING_REF;
        }
        
        ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
            
            allObjects.forEach { (snapshot) in
            
                let userId = snapshot.key;
                
                Database.fetchUser(with: userId) { (user) in
                    
                    self.users.append(user);
                    
                    self.tableView.reloadData();
                    
                }
            }
        }
    }
    
    // MARK: - FollowCellDelegate Handlers
    
    func handleFollowTapped(for cell: FollowCell)
    {
        
        guard let user = cell.user else { return};
        
        if user.isFollowed
        {
            
            user.unfollow();
            
            // configure follow button for non followed user
            cell.followButton.setTitle("Follow", for: .normal);
            cell.followButton.setTitleColor(.white, for: .normal);
            cell.followButton.layer.borderWidth = 0;
            cell.followButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1);
            
            
        }else
        {
            user.follow();
            
            cell.followButton.setTitle("Following", for: .normal);
            cell.followButton.setTitleColor(.black, for: .normal);
            cell.followButton.layer.borderWidth = 0.5;
            cell.followButton.layer.backgroundColor = UIColor.lightGray.cgColor;
            cell.followButton.backgroundColor = .white;
            
        }
        
    }
    
    
}
