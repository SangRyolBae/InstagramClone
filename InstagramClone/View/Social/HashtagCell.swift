//
//  HashtagCell.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/20.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit

class HashtagCell: UICollectionViewCell
{
    
    // MARK: - Properties
    var post: Post?
    {
        didSet
        {
            print( "Did set post" );
            
            guard let imageUrl = post?.imageUrl else {return};
            
            postImageView.loadImage(with: imageUrl);
            
        }
    }
    
    let postImageView: CustomImageView = {
        
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        
        return iv;
    }();
    
    
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame);
        
        addSubview(postImageView);
        postImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
