//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by 배상렬 on 14/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit

var imageCache = [String: UIImage]();

class CustomImageView: UIImageView
{
    var lastImgUrlUserdToLoadImage: String?;
    
    func loadImage(with urlString: String)
    {
        // set image to nil
        self.image = nil;
        
        // set lastImgUrlUsedToLoadImage
        lastImgUrlUserdToLoadImage = urlString;
        
        // check if image exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage;
            return;
        }
        
        // url for image location
        guard let url = URL(string: urlString) else {return};
        
        // fetch contents of URL
        URLSession.shared.dataTask(with: url) { (data, response, error) in
                    
            // handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription);
                return;
            }
            
            if self.lastImgUrlUserdToLoadImage != url.absoluteString
            {
                print("If block executed \(String(describing: self.lastImgUrlUserdToLoadImage))");
                return;
            }
            
            // image data
            guard let imageData = data else {return};
            
            // create image using image data
            let photoImage = UIImage(data: imageData);
            
            // set key and value for image cache
            imageCache[url.absoluteString] = photoImage;
            
            // set image
            DispatchQueue.main.async {
                self.image = photoImage;
            }
            
        }.resume();
        
    }
}
