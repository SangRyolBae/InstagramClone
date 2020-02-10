//
//  UserProfileHeader.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit

class UserProfileHeader: UICollectionViewCell
{
    
    let profileImageView: UIImageView = {
        let iv = UIImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        return iv;
    }();
    
    let nameLabel:UILabel = {
        let label = UILabel();
        label.text = "Username";
        label.font = UIFont.boldSystemFont(ofSize: 12);
        return label;
    }();
    
    let postsLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "posts", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        return label;
    }();
    
    let followersLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        return label;
    }();
    
    let followingLabel:UILabel = {
        let label = UILabel();
        label.numberOfLines = 0;
        label.textAlignment = .center;
        
        let attributesText = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)]);
        attributesText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributesText;
        
        return label;
    }();
    
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system);
        button.setTitle("Edit Profile", for: .normal);
        button.layer.cornerRadius = 3;
        button.layer.borderColor = UIColor.lightGray.cgColor;
        button.layer.borderWidth = 0.5;
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14);
        button.setTitleColor(.black, for: .normal);
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
    
    override init(frame: CGRect)
    {
        super.init(frame:frame);
        
        addSubview(profileImageView);
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80);
        profileImageView.layer.cornerRadius = 80 / 2;
        
        addSubview(nameLabel);
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
        configureUserStats();
        
        addSubview(editProfileButton);
        editProfileButton.anchor(top: postsLabel.bottomAnchor, left: postsLabel.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 4, paddingLeft: 8, paddingBottom: 0, paddingRight: 12, width: 0, height: 30);
        
        configureButtonToolBar();
    }
    
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
