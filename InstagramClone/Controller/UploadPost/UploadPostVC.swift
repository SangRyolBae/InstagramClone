//
//  UploadPostVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class UploadPostVC: UIViewController, UITextViewDelegate
{

    // MARK: - Properties
    
    enum UploadAction: Int {
        case UploadPost
        case SaveChanges
        
        init(index: Int) {
            switch index {
            case 0: self = .UploadPost
            case 1: self = .SaveChanges
            default: self = .UploadPost
            }
        }
    }
    
    var uploadAction: UploadAction!
    var selectedImage:UIImage?
    var postToEdit: Post?
    
    let photoImageView: CustomImageView = {
           
           let iv = CustomImageView();
           iv.contentMode = .scaleAspectFill;
           iv.clipsToBounds = true;
           iv.backgroundColor = .lightGray;
           
           return iv;
       }();
    
    let captionTextView: UITextView = {
        
        let tv = UITextView();
        tv.backgroundColor = UIColor.groupTableViewBackground;
        tv.font = UIFont.systemFont(ofSize: 12);
        return tv;
        
    }();
    
    lazy var actionButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
        button.setTitle("Share", for: .normal);
        button.setTitleColor(.white, for: .normal);
        button.layer.cornerRadius = 5;
        button.isEnabled = false;
        button.addTarget(self, action: #selector(handleUploadAction), for: .touchUpInside)
        
        return button;
    }();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // configure view components
        configureViewComponents();
        
        // load image
        loadImage();
        
        // text view delegate
        captionTextView.delegate = self;
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if uploadAction == .SaveChanges
        {
            guard let post = self.postToEdit else {return}
            guard let imageUrl = post.imageUrl else {return};
            guard let caption = post.caption else {return};
            
            photoImageView.loadImage(with: imageUrl);
            
            captionTextView.text = caption;
            
            actionButton.setTitle("Save Changes", for: .normal);
            
            self.navigationItem.title = "Edit Post";
            
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(handleCancel));
            navigationController?.navigationBar.tintColor = .black;
            
        } else
        {
            actionButton.setTitle("Share", for: .normal);
            
            self.navigationItem.title = "Upload Post";
        }
        
    }
    
    // MARK: - API
    func configureViewComponents()
    {
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 160, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100);
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 160, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100);
        
        view.addSubview(actionButton)
        actionButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40);
    }
    
    func loadImage()
    {
        guard let selectedimage = self.selectedImage else { return };
        
        photoImageView.image = selectedimage;
    }
    
    func uploadHashtagToServer(withPostId postId: String)
    {
        
        guard let caption = captionTextView.text else {return};
        
        let words: [String] = caption.components(separatedBy: .whitespacesAndNewlines);
        
        for var word in words
        {
            if word.hasPrefix("#")
            {
                
                word = word.trimmingCharacters(in: .punctuationCharacters);
                word = word.trimmingCharacters(in: .symbols);
                
                let hashtagValues = [postId: 1] as [String: Any];
                
                HASHTAG_POST_REF.child(word.lowercased()).updateChildValues(hashtagValues);
                
            }
        }
        
    }
    
    // MARK: - Handlers
    func updateUserFeeds(with postId:String)
    {
        // current user id
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        // database values
        let values = [postId: 1];
        
        // update follower feeds
        USER_FOLLOWER_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerUid = snapshot.key;
            
            USER_FEED_REF.child(followerUid).updateChildValues(values);
            
        }
        
        // update current user feed
        USER_FEED_REF.child(currentUid).updateChildValues(values);
        
    }
    
    @objc
    func handleUploadAction()
    {
        buttonSelector(uploadAction: uploadAction);
    }
    
    func buttonSelector(uploadAction: UploadAction)
    {
    
        switch uploadAction
        {
        case .UploadPost:
            handleUploadPost();
            
        case .SaveChanges:
            handleSavePostChanges();
        }
        
    }
    
    func handleSavePostChanges()
    {
        guard let post = self.postToEdit else { return };
        guard let postId = post.postId else { return };
        
        let updatedCaption = captionTextView.text;
        
        uploadHashtagToServer(withPostId: postId);
        
        POSTS_REF.child(postId).child("caption").setValue(updatedCaption) { (err, ref) in
            
            self.dismiss(animated: true, completion: nil);
            
        }
        
    }
    
    func handleUploadPost()
    {
        // paramaters
        guard
            let caption = captionTextView.text,
            let postImg = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else {return};
        
        // image upload data
        guard let uploadData = postImg.jpegData(compressionQuality: 0.5) else {return};
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970);
        
        // update storage
        let filename = NSUUID().uuidString;
        
        
        // Profile 이미지 업로드
        let storageRef = Storage.storage().reference().child("post_images").child(filename);
        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
            
            // handle error
            if let error = error{
                print("Failed to update image to Firebase Storage with error", error.localizedDescription);
                return;
            }
            
            // 이미지 업로드 완료 후 Db에 저장
            storageRef.downloadURL(completion: { (downloadURL, error) in
                
                guard let postImageURL = downloadURL?.absoluteString else {
                    print("DEBUG : Profile image url is nil");
                    return;
                }
                
                
                let values = [ "caption" : caption,
                               "creationDate": creationDate,
                               "likes":0,
                               "imageUrl":postImageURL,
                               "ownerUid":currentUid] as [String:Any];
                
                // post id
                let postId = POSTS_REF.childByAutoId();
                guard let postKey = postId.key else { return }
                
                // upload information to database
                postId.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    // update user-post structure
                    let userPostsRef = USER_POSTS_REF.child(currentUid)
                    userPostsRef.updateChildValues([postKey: 1])
                    
                    // update user-feed structure
                    self.updateUserFeeds(with: postKey);
                    
                    // upload hashtag to server
                    self.uploadHashtagToServer(withPostId: postKey);
                    
                    // upload mention notification to server
                    if caption.contains("@")
                    {
                        self.uploadMentionNotificationToServer(forPostId: postKey, withText: caption, isForComment: false);
                    }
                    
                    // return to home feed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0;
                    });
                    
                });
                
            });
            
        })
        
    }
    
    @objc
    func handleCancel()
    {
        print( "HANDLE CANCEL");
        self.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - UITextView
    func textViewDidChange(_ textView: UITextView) {
        
        guard !textView.text.isEmpty else {
            
            actionButton.isEnabled = false;
            actionButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
            return;
        }
        
        actionButton.isEnabled = true;
        actionButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1);
        
    }
    
    
}
