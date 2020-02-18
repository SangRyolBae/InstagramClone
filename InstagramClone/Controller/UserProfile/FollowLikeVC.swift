//
//  FollowVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 11/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase;

private let reuseIdentifer = "FollowLikeCell";

class FollowLikeVC: UITableViewController, FollowCellDelegate
{
    
    // MARK: - Properties
    
    enum ViewingMode : Int
    {
        case Following
        case Followers
        case Likes
        
        init(index: Int)
        {
            switch index
            {
            case 0:
                self = .Following;
            case 1:
                self = .Followers;
            case 2:
                self = .Likes;
            default:
                self = .Following;
            }
        }
    }
    
    var postId:String?;
    var viewingMode: ViewingMode!;
    var uid: String?;
    var users = [User]();
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell class
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdentifer);
        
       // configure nav titles
        configureNavigationTitle();
        
        // fetch users
        fetchUsers();

        // clear separator lines
        tableView.separatorColor = .clear;
        
        print("Viewing mode integer value is ", viewingMode.rawValue);
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! FollowLikeCell;
        
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
    
    // MARK: - Handlers
    func configureNavigationTitle()
    {
        guard let viewingMode = self.viewingMode else {return};
        
        switch viewingMode
        {
            case .Followers:
                navigationItem.title = "Followers";
            case .Following:
                navigationItem.title = "Following";
            case .Likes:
                navigationItem.title = "Likes";
        }
    }
    
    // MARK: - API
    
    func getDatabaseReference() -> DatabaseReference?
    {
        guard let viewingMode = self.viewingMode else {return nil};
        
        switch viewingMode
        {
        case .Followers: return USER_FOLLOWER_REF;
        case .Following: return USER_FOLLOWING_REF;
        case .Likes: return POST_LIKES_REF;
        }
    }
    
    func fetchUser(with uid: String)
    {
        Database.fetchUser(with: uid) { (user) in
            
            self.users.append(user);
            
            self.tableView.reloadData();
            
        }
    }
    
    func fetchUsers()
    {
        guard let ref = getDatabaseReference() else {return};
        guard let viewingMode = self.viewingMode else {return};
        
        switch viewingMode
        {
        case .Following, .Followers:
            
            guard let uid = self.uid else { return };
            
            ref.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                
                    let uid = snapshot.key;
                    
                    self.fetchUser(with: uid);
                }
            }
        case .Likes:
                        
            guard let postId = self.postId else { return };
            
            ref.child(postId).observe(.childAdded, with: { (snapshot) in
                
                let uid = snapshot.key;
                
                self.fetchUser(with: uid);
                
            })
        }
        
        
    }
    
    // MARK: - FollowCellDelegate Handlers
    
    func handleFollowTapped(for cell: FollowLikeCell)
    {
        
        guard let user = cell.user else { return};
        
        if user.isFollowed
        {
            
            user.unfollow();
            
            cell.followButton.configure(didFollow: false);
            
        }else
        {
            user.follow();
            
            cell.followButton.configure(didFollow: true);
            
        }
        
    }
    
    
}
