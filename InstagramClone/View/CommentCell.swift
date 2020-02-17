//
//  CommentCell.swift
//  InstagramClone
//
//  Created by 배상렬 on 17/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class CommentCell: UICollectionViewCell
{
    // MARK: - Properties
    var comment: Comment?
    {
        didSet
        {
            
            guard let user = comment?.user else {return};
            guard let profileImageUrl = user.profileImageUrl else {return};
            guard let username = user.username else {return};
            guard let commentText = comment?.commentText else {return};
            
            self.profileImageView.loadImage(with: profileImageUrl);
            
            let attributesText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]);
            attributesText.append(NSAttributedString(string: " \(commentText)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]));
           
            attributesText.append(NSAttributedString(string: " 2d.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                                NSAttributedString.Key.foregroundColor: UIColor.lightGray]));
           
               
            commentTextView.attributedText = attributesText;
        }
    }
    
    let profileImageView: CustomImageView = {
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        return iv;
    }();
    
    let commentTextView: UITextView = {
    
        let tv = UITextView();
        tv.font = UIFont.systemFont(ofSize: 12);
        tv.isScrollEnabled = false;
        
        let attributesText = NSMutableAttributedString(string: "Username", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)]);
        attributesText.append(NSAttributedString(string: " Some test comment", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]));
        
        attributesText.append(NSAttributedString(string: " 2d.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
                                                                             NSAttributedString.Key.foregroundColor: UIColor.lightGray]));
        
        
        tv.attributedText = attributesText;
        
        return tv;
        
    }();
    
    let separatorView: UIView = {
        
        let view = UIView();
        
        view.backgroundColor = .lightGray
        
        return view;
    }();
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        // add profile image view
        addSubview(profileImageView);
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40);
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true;
        profileImageView.layer.cornerRadius = 40 / 2;
        
        addSubview(commentTextView);
        commentTextView.anchor(top: topAnchor, left: profileImageView.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 4, paddingLeft: 4, paddingBottom: 4, paddingRight: 4, width: 0, height: 0);
       
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
