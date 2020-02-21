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
    var followCurrentKey: String?
    var likeCurrentKey: String?
    
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if users.count > 3
        {
            if indexPath.item == users.count - 1 {
                fetchUsers();
            }
        }
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
            
            fetchUsersFollow();
            
        case .Likes:
                      
            fetchUsersLike();
        }
    }
    
    func fetchUsersFollow()
    {
        guard let ref = getDatabaseReference() else {return};
        guard let uid = self.uid else { return };
        
        if followCurrentKey == nil
        {
            
            ref.child(uid).queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                
                //self.collectionView?.refreshControl?.endRefreshing();
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    self.fetchUser(with: uid);
                }
                
                self.followCurrentKey = first.key;
            }
            
        }else
        {
            ref.child(uid).queryOrderedByKey().queryEnding(atValue: self.followCurrentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    if uid != self.followCurrentKey {
                        self.fetchUser(with: uid);
                    }
                }
                
                self.followCurrentKey = first.key;
                
            }
            
        }
    }
    
    func fetchUsersLike()
    {
        guard let ref = getDatabaseReference() else {return};
        guard let postId = self.postId else { return };
        
        if likeCurrentKey == nil
        {
            
            ref.child(postId).queryLimited(toLast: 4).observeSingleEvent(of: .value) { (snapshot) in
                
                //self.collectionView?.refreshControl?.endRefreshing();
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    self.fetchUser(with: uid);
                }
                
                self.likeCurrentKey = first.key;
            }
            
        }else
        {
            ref.child(postId).queryOrderedByKey().queryEnding(atValue: self.likeCurrentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let uid = snapshot.key
                    
                    if uid != self.likeCurrentKey {
                        self.fetchUser(with: uid);
                    }
                }
                
                self.likeCurrentKey = first.key;
                
            }
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
