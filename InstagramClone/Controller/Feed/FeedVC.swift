//
//  FeedVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {
    
    // MARK: - Properties
    
    var posts = [Post]();
    var viewSinglePost = false;
    var post:Post?;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        collectionView.backgroundColor = .white;
        
        // Register cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure refresh control
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged);
        collectionView?.refreshControl = refreshControl;
        
        // configure navigation bar
        configureNavigationBar();
        
        // fetch Posts
        if !viewSinglePost {
            fetchPosts();
        }
        
        updateUserFeeds();
    }

    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let width = view.frame.width;
        var height = width + 8 + 40 + 8;
        height += 50;
        height += 60;
        
        return CGSize(width: width, height: height);
    }
    
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if(viewSinglePost)
        {
            return 1;
        }else
        {
            return posts.count;
        }
            
    }

    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
    
        // Configure the cell
        cell.delegate = self;
        
        if(viewSinglePost)
        {
            if let post = self.post
            {
                cell.post = post;
            }
            
        }else
        {
            cell.post = posts[indexPath.row];
        }
        
        return cell
    }
    
    // MARK: - APIs
    
    func configureNavigationBar()
    {
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages));
        
        self.navigationItem.title = "Feed";
    }
    
    func fetchPosts()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key;
            
            Database.fetchPost(with: postId) { (post) in
                    
                self.posts.append(post);
                
                self.posts.sort { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate;
                }
                
                //stop refreshing;
                self.collectionView?.refreshControl?.endRefreshing();
                
                self.collectionView?.reloadData();
                
            }
        }
    }
    
    func updateUserFeeds()
    {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followingUserId = snapshot.key;
            
            USER_POSTS_REF.child(followingUserId).observe(.childAdded) { (snapshot) in
                
                let postId = snapshot.key;
                
                USER_FEED_REF.child(currentUid).updateChildValues([postId: 1]);
            }
        }

        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key;
            
            USER_FEED_REF.child(currentUid).updateChildValues([postId:1]);
        }
    }
    
    
    // MARK: - Handlers
       
    @objc
    func handleShowMessages()
    {
        print("Handle show messages");
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
        fetchPosts();
        collectionView?.reloadData();
    }
    
    // MARK: - FeedCellDelegate Protocol Handlers
    func handleUsernameTapped(for cell:FeedCell)
    {
        guard let post = cell.post else { return};
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout());
        
        userProfileVC.user = post.user;
        
        navigationController?.pushViewController(userProfileVC, animated: true);
    }
    
    func handleOptionTapped(for cell:FeedCell)
    {
        
    }
    
    func handleLikeTapped(for cell:FeedCell)
    {
        guard let post = cell.post else { return};
        
        if (post.didLike)
        {
           
            post.adjectLikes(addLike: false, completion: { (likes) in
                
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal);
                cell.likesLabel.text = "\(likes) likes";
                
            });
            
        }else
        {
            post.adjectLikes(addLike: true, completion: { (likes) in
                
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal);
                cell.likesLabel.text = "\(likes) likes";
                
            });
            
        }
    }
    
    func handleCommentTapped(for cell:FeedCell)
    {
        
    }
    
    func handleConfigureLikeButton(for cell: FeedCell)
    {
        guard let post = cell.post else {return};
        guard let postId = post.postId else {return};
        guard let currentUid = Auth.auth().currentUser?.uid else {return}; 
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(postId)
            {
                print("User has liked post");
                
                post.didLike = true;
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal);
                
            }
            
        }  
        
    }
    
    func handleShowLikes(for cell: FeedCell) {
        
        print("handle show likes");
        
        guard let post = cell.post else {return};
        guard let postId = post.postId else {return};
        
        let followLikeVC = FollowLikeVC();
        
        followLikeVC.viewingMode = FollowLikeVC.ViewingMode(index: 2);
        followLikeVC.postId = postId;
        navigationController?.pushViewController(followLikeVC, animated: true);
    }
    
    
    

}
