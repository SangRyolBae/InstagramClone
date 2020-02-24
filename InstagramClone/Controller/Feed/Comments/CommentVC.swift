//
//  CommentVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 17/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import Foundation
import Firebase

private let reuseIdentifier = "Cell"

class CommentVC: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    // MARK: - Properties
    
    var comments = [Comment]();
    var post: Post?;
    
    lazy var containerView: CommentInputAccesoryView = {
        
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50);
        
        let containerView = CommentInputAccesoryView(frame: frame);
       
        containerView.delegate = self;
        
        return containerView;
    }();
    
    
    // MARK: - Super
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // configure collection view
        collectionView?.backgroundColor = .white;
        collectionView?.alwaysBounceVertical = true;
        collectionView?.keyboardDismissMode = .interactive;
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0);
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0);
        
        // navigation title
        navigationItem.title = "Comments";
        
        // register cell class
        self.collectionView!.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // fetch comments
        fetchComments();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        tabBarController?.tabBar.isHidden = true;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        tabBarController?.tabBar.isHidden = false;
    }
    
    override var inputAccessoryView: UIView?
        {
        get
        {
            return containerView;
        }
    }
    
    override var canBecomeFirstResponder: Bool
    {
        return true;
    }
    
    // MARK: - CollectionView
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50);
        
        let dummyCell = CommentCell(frame: frame);
        dummyCell.comment = comments[indexPath.row];
        dummyCell.layoutIfNeeded();
        
        let targetSize = CGSize(width: view.frame.width, height: 1000);
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize);
        
        let height = max(40 + 8 + 8, estimatedSize.height);
        return CGSize(width: view.frame.width, height: height);
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        
        handleHashtagTapped(forCell: cell);
        handleMentionTapped(forCell: cell);
        
        cell.comment = comments[indexPath.row];
        
        return cell;
    }
    
    // MARK: - Handlers
        
    func handleHashtagTapped(forCell cell: CommentCell)
    {
        cell.commentLabel.handleHashtagTap { (hashtag) in
            
            print("HashTag is \(hashtag)");
            
            let hashtagController = HashtagController(collectionViewLayout: UICollectionViewFlowLayout());
            hashtagController.hashtag = hashtag;
            self.navigationController?.pushViewController(hashtagController, animated: true);
        }
    }
    
    func handleMentionTapped(forCell cell: CommentCell)
    {
        cell.commentLabel.handleMentionTap { (username) in
            
            print("Mention is \(username)");
            self.getMentionedUser(withUsername: username);
        }
    }
    
    // MARK: - APIs
    func fetchComments()
    {
        guard let post = self.post else {return};
        guard let postId = post.postId else {return};
        
        COMMENT_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return};
            guard let uid = dictionary["uid"] as? String else {return};
            
            Database.fetchUser(with: uid) { (user) in
                
                let comment = Comment(user: user, dictionary: dictionary);
                
                self.comments.append(comment);
                
                self.collectionView?.reloadData();
                
            }
        }
    }
    
    func uploadCommentNotificationToServer()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        guard let post = self.post else {return};
        guard let postId = post.postId else {return};
        guard let uid =  post.user?.uid else {return};
        let creationDate = Int(NSDate().timeIntervalSince1970);
        
        // notification values
        let values = [ "checked" : 0,
                       "creationDate" : creationDate,
                       "uid" : currentUid,
                       "type" : COMMENT_INT_VALUE,
                       "postId" : postId
            ] as [String: AnyObject];
        
        // upload comment notification to server
        if uid != currentUid
        {
            NOTIFICATIONS_REF.child(uid).childByAutoId().updateChildValues(values);
        }
        
    }
}

// MARK: - CommentVC: CommentInputAccesoryViewDelegate
extension CommentVC: CommentInputAccesoryViewDelegate
{
    func didSubmit(forComment comment: String)
    {
        guard let post = self.post else {return};
        guard let postId = post.postId else {return};
        guard let uid = Auth.auth().currentUser?.uid else {return};
        let creationDate = Int(NSDate().timeIntervalSince1970);
        
        let values = [ "commentText" : comment,
                       "creationDate" : creationDate,
                       "uid" : uid
            ] as [String : Any];
        
        COMMENT_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            
            self.uploadCommentNotificationToServer();
            
            if comment.contains("@")
            {
                self.uploadMentionNotificationToServer(forPostId: postId, withText: comment, isForComment: true);
            }
            
            
            self.containerView.clearCommentTextView();
            
        }
    }
}
