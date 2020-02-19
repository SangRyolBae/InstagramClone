//
//  FeedCell.swift
//  InstagramClone
//
//  Created by 배상렬 on 14/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class FeedCell: UICollectionViewCell
{
    
    // MARK: - Properties
    
    var delegate: FeedCellDelegate?;
    
    var post: Post?
    {
        didSet
        {
            guard let ownerUid = post?.ownerUid else {return};
            guard let imageUrl = post?.imageUrl else {return};
            guard let likes = post?.likes else {return};
            guard let timestamp = getFeedTimeStamp() else {return};
            
            // User info
            Database.fetchUser(with: ownerUid) { (user) in
                
                self.profileImageView.loadImage(with: user.profileImageUrl);
                self.usernameButton.setTitle(user.username, for:.normal);
                
                self.configurePostCaption(user: user);
            }
            
            self.postImageView.loadImage(with: imageUrl);
            self.likesLabel.text = "\(likes) likes";
            self.postTimeLabel.text = timestamp;
            
            configureLikeButton();
        }
    }
    
    
    let profileImageView: CustomImageView = {
        
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        
        return iv;
    }();
    
    lazy var usernameButton: UIButton = {
    
        let button = UIButton(type: .system)
        button.setTitle("Username", for: .normal);
        button.setTitleColor(.black, for: .normal);
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12);
        button.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside);
        return button

    }();
    
    lazy var optionsButton: UIButton = {
    
        let button = UIButton(type: .system);
        button.setTitle("•••", for: .normal);
        button.setTitleColor(.black, for: .normal);
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside);
        return button;
        
    }();
    
    lazy var postImageView: CustomImageView = {
        
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        
        // add gesture recognizer for double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapToLike));
        likeTap.numberOfTapsRequired = 2;
        iv.isUserInteractionEnabled = true;
        iv.addGestureRecognizer(likeTap);
        
        return iv;
    }();
    
    lazy var likeButton: UIButton = {
    
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal);
        button.tintColor = .black;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside);
        return button;
        
    }();
    
    lazy var commentButton: UIButton = {
    
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "comment"), for: .normal);
        button.tintColor = .black;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        button.addTarget(self, action: #selector(handleCommandTapped), for: .touchUpInside);
        return button;
        
    }();
    
    let messageButton: UIButton = {
    
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "send2"), for: .normal);
        button.tintColor = .black;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        return button;
        
    }();
    
    let savePostButton: UIButton = {
    
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal);
        button.tintColor = .black;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        return button;
        
    }();
    
    lazy var likesLabel: UILabel = {
        
        let label = UILabel();
        label.font = UIFont.boldSystemFont(ofSize: 12);
        label.text = "3 likes";
        
        // add gesture recognizer to label
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes));
        likeTap.numberOfTouchesRequired = 1;
        label.isUserInteractionEnabled = true;
        label.addGestureRecognizer(likeTap);
        
        return label;
        
    }();
    
    let captionLabel: ActiveLabel = {
        
        let label = ActiveLabel();
        label.numberOfLines = 0;
        return label;
        
    }();
    
    let postTimeLabel: UILabel = {
        
        let label = UILabel();
        
        label.textColor = .lightGray;
        label.font = UIFont.boldSystemFont(ofSize: 10);
        
        return label;
        
    }();
    
    // MARK: - Handlers
    @objc
    func handleUsernameTapped()
    {
        delegate?.handleUsernameTapped(for: self);
    }
    
    @objc
    func handleOptionsTapped()
    {
        delegate?.handleOptionTapped(for: self);
    }
    
    @objc
    func handleLikeTapped()
    {
        delegate?.handleLikeTapped(for: self, isDoubleTap: false);
    }
    
    @objc
    func handleCommandTapped()
    {
        delegate?.handleCommentTapped(for: self);
    }
    
    @objc
    func handleShowLikes()
    {
        delegate?.handleShowLikes(for: self);
    }
    
    @objc
    func handleDoubleTapToLike()
    {
        delegate?.handleLikeTapped(for: self, isDoubleTap: true);
    }
    
    
    // MARK: - APIs
    
    func configureLikeButton()
    {
        delegate?.handleConfigureLikeButton(for: self);
    }
    
    func configureActionButtons()
    {
        
        let stackView = UIStackView(arrangedSubviews: [likeButton, commentButton, messageButton]);
        
        stackView.axis = .horizontal;
        stackView.distribution = .fillEqually;
        
        addSubview(stackView);
        stackView.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 120, height: 50);
        
        addSubview(savePostButton);
        savePostButton.anchor(top: postImageView.bottomAnchor, left: nil, bottom: nil, right: rightAnchor, paddingTop: 12, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 20, height: 24);
        
        
    }
    
    
    func configurePostCaption(user: User)
    {
        guard let post = self.post else { return };
        guard let caption = post.caption else { return};
        guard let username = post.user?.username else {return};
        
        // look for username as pattern
        let customType = ActiveType.custom(pattern: "^\(username)\\b");
        
        // enable username as custom type
        captionLabel.enabledTypes = [.mention, .hashtag, .url, customType];
        
        // configure username link attributes
        captionLabel.configureLinkAttribute = { (type, attributes, isSelected) in
            var atts = attributes;
            
            switch type
            {
            case .custom:
                atts[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 12);
            default: ()
            }
            
            return atts;
        }
        
        captionLabel.customize { (label) in
            
            label.text = "\(username) \(caption)"
            label.customColor[customType] = .black;
            label.font = UIFont.systemFont(ofSize: 12);
            label.textColor = .black;
            captionLabel.numberOfLines = 2;
        }
        
        postTimeLabel.text = "2 DAYS AGO";
    }
    
    
    func getFeedTimeStamp() -> String?
    {
        guard let post = self.post else { return nil};
        
        let dateFormatter = DateComponentsFormatter();
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth];
        dateFormatter.maximumUnitCount = 1;
        dateFormatter.unitsStyle = .abbreviated;
        
        let now = Date();
        return dateFormatter.string(from: post.creationDate, to: now);
    }
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        addSubview(profileImageView);
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40);
        profileImageView.layer.cornerRadius = 40 / 2
        
        addSubview(usernameButton);
        usernameButton.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        usernameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true;
        
        addSubview(optionsButton);
        optionsButton.anchor(top: nil, left: nil, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 8, width: 0, height: 0);
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true;
        
        addSubview(postImageView);
        postImageView.anchor(top: profileImageView.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true;
        
        
        // configure action buttons
        configureActionButtons();
        
        addSubview(likesLabel);
        likesLabel.anchor(top: self.likeButton.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: -4, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
        addSubview(captionLabel);
        captionLabel.anchor(top: self.likesLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0);
        
        addSubview(postTimeLabel);
        postTimeLabel.anchor(top: self.captionLabel.bottomAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
