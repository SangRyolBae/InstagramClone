//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class UserProfileHeader: UICollectionViewCell
{
    // MARK: - Properties
    
    var delegate: UserProfileHeaderDelegate?
    
    var user: User?
    {
        
        // Observer라고 생각하면은 됨
        didSet
        {
            
            // configure edit profile button
            configureEditProfileFollowButton();
            
            // set user stats
            setUserStats(for: user);
            
            let fullName = user?.name;
            nameLabel.text = fullName;
            
            guard let profileImageUrl = user?.profileImageUrl else {return};
            profileImageView.loadImage(with: profileImageUrl);
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        return iv;
    }();
    
    let nameLabel:UILabel = {
        let label = UILabel();
        label.font = UIFont.boldSystemFont(ofSize: 12);
        return label;
    }();
    
    let postsLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        return label;
    }();
    
    lazy var followersLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        // add gesture recognizer
        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped));
        followTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true;
        label.addGestureRecognizer(followTap);
        
        return label;
    }();
    
    lazy var followingLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "-\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        // add gesture recognizer
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped));
        followingTap.numberOfTapsRequired = 1
        label.isUserInteractionEnabled = true;
        label.addGestureRecognizer(followingTap);
        
        return label;
    }();
    
    lazy var editProfileFollowButton: UIButton = {
        let button = UIButton(type: .system);
        button.setTitle("Loading", for: .normal);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = UIColor.lightGray.cgColor;
        button.layer.borderWidth = 0.5;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        button.setTitleColor(.black, for: .normal);
        button.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        return button;
    }();
       
    let gridButton: UIButton = {
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal);
        return button;
    }();
        
    let listButton: UIButton = {
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal);
        button.tintColor = UIColor(white: 0, alpha: 0.2);
        return button;
    }();
        
    let bookmarkButton: UIButton = {
        let button = UIButton(type: .system);
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal);
        button.tintColor = UIColor(white: 0, alpha: 0.2);
        return button;
    }();
    
    // MARK: - API
    
    func configureButtonToolBar()
    {
        let topDividerView = UIView();
        topDividerView.backgroundColor = .lightGray;
        
        let bottomDividerView = UIView();
        bottomDividerView.backgroundColor = .lightGray;
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton]);
        
        stackView.axis = .horizontal;
        stackView.distribution = .fillEqually;
        
        addSubview(topDividerView);
        addSubview(stackView);
        addSubview(bottomDividerView);
        
        stackView.anchor(top: nil, left: leftAnchor, bottom: self.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50);
        
        topDividerView.anchor(top: stackView.topAnchor, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5);
        
        bottomDividerView.anchor(top: nil, left: leftAnchor, bottom: stackView.bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5);
        
    }
    
    func configureUserStats()
    {
        let stackView = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel]);
        
        stackView.axis = .horizontal;
        stackView.distribution = .fillEqually;
        
        addSubview(stackView);
        
        stackView.anchor(top: self.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 50);
    }
    
    func setUserStats(for user: User?)
    {
        delegate?.setUserStats(for: self);
    }
    
    
    func configureEditProfileFollowButton()
    {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        guard let user = self.user else { return };
        
        if currentUid == user.uid
        {
            
            // configure button as edit profile
            self.editProfileFollowButton.setTitle("Edit Profile", for: .normal);
            
        }else
        {
            // configure button as follow button
            self.editProfileFollowButton.setTitleColor(.white, for: .normal);
            self.editProfileFollowButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1);
            
            user.checkIfUserIsFollowed(completion: { (followed) in
                
                if followed {
                    self.editProfileFollowButton.setTitle("Following", for: .normal);
                }else
                {
                    self.editProfileFollowButton.setTitle("Follow", for: .normal);
                }
            });
        }
    }
    
   
    // MARK: - Handlers
    @objc
    func handleEditProfileFollow()
    {
        delegate?.handleEditFollowTapped(for: self);
    }
    
    @objc
    func handleFollowersTapped()
    {
        print( "function call handleFollowersTapped");
        
        delegate?.handleFollowersTapped(for: self);
    }
    
    @objc
    func handleFollowingTapped()
    {
        print( "function call handleFollowingTapped");
        
        delegate?.handleFollowingTapped(for: self);
    }
    
   
    
    
    // MARK: - Initialize
    
    override init(frame: CGRect)
    {
        super.init(frame:frame);
        
        addSubview(profileImageView);
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80);
        profileImageView.layer.cornerRadius = 80 / 2;
        
        addSubview(nameLabel);
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
        configureUserStats();
        
        addSubview(editProfileFollowButton);
        editProfileFollowButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30);
        
        configureButtonToolBar();
    }
    
    required init?(coder: NSCoder)
    {
       fatalError("init(coder:) has not been implemented")
    }
       
}
