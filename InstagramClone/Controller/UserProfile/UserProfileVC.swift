//
//  UserProfileVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate
{
    // MARK: - Properties
    
    var user: User?;
    var posts = [Post]();
    var currentKey: String?
    
    
    // MARK: - Init
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier);
        
        // configure refresh control
        configureRefreshControl();
        
        // background color
        self.collectionView.backgroundColor = .white;
        
        // fetch user data
        if nil == user
        {
            fetchCurrentUserData();
        }
        
        // fetch posts
        fetchPosts();
        
        if let user = self.user
        {
            print("Username from previous controller is \(user.username)");
        }
        
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 2 ) / 3
        
        return CGSize(width: width, height: width);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    
    // MARK: - UICollectionView
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        if posts.count > 9
        {
            if indexPath.item == posts.count - 1
            {
                fetchPosts();
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count;
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader;
        
        // self delegate
        header.delegate = self;
        
        // set the user in header
        header.user = self.user;
        navigationItem.title = self.user?.username;
        
        // return header
        return header;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        
        // Configure the cell
        cell.post = posts[indexPath.row];
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let feedVC = FeedVC(collectionViewLayout: UICollectionViewFlowLayout());
        
        feedVC.viewSinglePost = true;
        feedVC.userProfileController = self;
        
        feedVC.post = posts[indexPath.item];
        
        navigationController?.pushViewController(feedVC, animated: true);
        
    }
    
    
    // MARK: - API
    func fetchPosts()
    {
        var uid:String!;
        
        if let user = self.user
        {
            uid = user.uid;
        }else
        {
            uid = Auth.auth().currentUser?.uid;
        }
        
        // initial data pull
        if nil == currentKey
        {
            USER_POSTS_REF.child(uid).queryLimited(toLast: 10).observeSingleEvent(of: .value) { (snapshot) in
                
                self.collectionView?.refreshControl?.endRefreshing();
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let postId = snapshot.key
                    
                    self.fetchPost(withPostId: postId);
                }
                
                self.currentKey = first.key;
                
            }
        }else
        {
            
            USER_POSTS_REF.child(uid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let postId = snapshot.key
                    
                    if postId != self.currentKey {
                        self.fetchPost(withPostId: postId);
                    }
                    
                }
                
                self.currentKey = first.key;
                
            }
        }
        
        
        
    }
    
    func fetchPost(withPostId postId:String)
    {
        
        Database.fetchPost(with: postId) { (post) in
            
            self.posts.append(post);
            
            self.posts.sort { (post1, post2) -> Bool in
                return post1.creationDate > post2.creationDate;
            }
            
            self.collectionView?.reloadData();
            
        }
    }
    
    
    func fetchCurrentUserData()
    {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        
        print("Current user id is \(currentUid)");
        
        // User name Setting
        let usersDB = Database.database().reference().child("users").child(currentUid);
        usersDB.observeSingleEvent(of: .value) { (snapshot) in
            
            //guard let username = snapshot.value as? String else {return}
            
            //self.navigationItem.title = username;
            
            print(snapshot);
            
            let uid = snapshot.key;
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return };
            
            let user = User(uid: uid, dictionary: dictionary);
            
            print( "Username is \(user.username)");
            
            self.user = user;
            self.navigationItem.title = user.username;
            self.collectionView?.reloadData();
        }
    }
    
    func configureLogoutButton()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    // MARK: - Handlers
    
    func configureRefreshControl()
    {
        let refreshControl = UIRefreshControl();
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged);
        
        collectionView.refreshControl = refreshControl;
    }
    
    @objc
    func handleLogout()
    {
        // declare alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        
        // add alert log out action
        alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            
            do {
                
                // attempt sign out
                try Auth.auth().signOut();
                
                // present login controller
                let loginVC = LoginVC();
                let navController = UINavigationController(rootViewController: loginVC);
                self.present(navController, animated: true, completion: nil);
                
                print( "Successfully logged user out");
                
            }catch {
                
                print("Failed to sign out");
                
            }
        }))
        
        // add cancel action
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
        
        present(alertController, animated: true, completion: nil);
    }
    
    @objc
    func handleRefresh()
    {
        posts.removeAll(keepingCapacity: false);
        self.currentKey = nil;
        fetchPosts();
        collectionView.reloadData();
    }
    
    // MARK: - UserProfileHeader Protocol
    
    func handleEditFollowTapped(for header: UserProfileHeader)
    {
        print( "handle edit follow tapped..");
        
        guard let user = header.user else { return };
        
        if header.editProfileFollowButton.titleLabel?.text == "Edit Profile"
        {
            let editProfileController = EditProfileController();
            editProfileController.user = user;
            editProfileController.userProfileController = self;
            let navigationController = UINavigationController(rootViewController: editProfileController);
            present(navigationController, animated: true, completion: nil);
            
        }else
        {
            
            // handles user follow/unfollow
            
            if header.editProfileFollowButton.titleLabel?.text == "Follow"
            {
                header.editProfileFollowButton.setTitle("Following", for: .normal);
                user.follow();
            }else
            {
                header.editProfileFollowButton.setTitle("Follow", for: .normal);
                user.unfollow();
            }
        }
    }
    
    func setUserStats(for header: UserProfileHeader)
    {
        guard let uid = header.user?.uid else {return};
        
        var numberOfFollowers: Int!;
        var numberOfFollowing: Int!;
        
        // get number of followers
        USER_FOLLOWER_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>
            {
                numberOfFollowers = snapshot.count;
            }else
            {
                numberOfFollowers = 0;
            }
            
            let attributesText = NSMutableAttributedString(string: "\(numberOfFollowers!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
            attributesText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]));
            
            header.followersLabel.attributedText = attributesText;
            
        }
        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            
            if let snapshot = snapshot.value as? Dictionary<String, AnyObject>
            {
                numberOfFollowing = snapshot.count;
            }else
            {
                numberOfFollowing = 0;
            }
            
            let attributesText = NSMutableAttributedString(string: "\(numberOfFollowing!)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
            attributesText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]));
            
            header.followingLabel.attributedText = attributesText;
            
        }
    }
    
    func handleFollowersTapped(for header: UserProfileHeader)
    {
        let followLikeVC = FollowLikeVC();
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 1);
        followLikeVC.uid = user?.uid;
        navigationController?.pushViewController(followLikeVC, animated: true);
    }
    
    func handleFollowingTapped(for header: UserProfileHeader)
    {
        let followLikeVC = FollowLikeVC();
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 0);
        followLikeVC.uid = user?.uid;
        navigationController?.pushViewController(followLikeVC, animated: true);
    }
    
}
