//
//  CommentInputTextView.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/24.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView
{

    let placeholderLabel: UILabel = {
       
        let label = UILabel();
        label.text = "Enter comment..";
        label.textColor = .lightGray;
        return label;
        
    }()
    
    @objc
    func handleInputTextChange()
    {
        placeholderLabel.isHidden = !self.text.isEmpty;
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?)
    {
        super.init(frame: frame, textContainer: textContainer);
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextChange), name: UITextView.textDidChangeNotification, object: nil);
        addSubview(placeholderLabel);
        placeholderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
