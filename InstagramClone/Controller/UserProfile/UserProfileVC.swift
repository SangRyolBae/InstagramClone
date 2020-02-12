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
    
    // MARK: - ViewDidLoad
    override func viewDidLoad()
    {
        
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier);
        
        // background color
        self.collectionView.backgroundColor = .white;
        
        // fetch user data
        if nil == user
        {
            fetchCurrentUserData();
        }
        
        if let user = self.user
        {
            print("Username from previous controller is \(user.username)");
        }
        
    }

    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
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

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    // MARKL - API
    
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
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    // MARK: - Handlers
    
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
        let followVC = FollowVC();
        followVC.viewFollowers = true;
        followVC.uid = user?.uid;
        navigationController?.pushViewController(followVC, animated: true);
    }
    
    func handleFollowingTapped(for header: UserProfileHeader)
    {
        let followVC = FollowVC();
        followVC.viewFollowing = true;
        followVC.uid = user?.uid;
        navigationController?.pushViewController(followVC, animated: true);
    }
    
}
