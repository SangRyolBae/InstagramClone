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
    
    override init(frame: CGRect)
    {
        super.init(frame:frame);
        
        addSubview(profileImageView);
        profileImageView.anchor(top: self.topAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 80, height: 80);
        profileImageView.layer.cornerRadius = 80 / 2;
        
        addSubview(nameLabel);
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: nil, paddingTop: 12, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
