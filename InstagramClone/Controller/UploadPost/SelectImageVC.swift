//
//  SelectImageVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 12/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell";
private let headerIdentifier = "SelectPhotoHeader";

class SelectImageVC: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    // MARK: - Properties
    var images = [UIImage]();
    var assets = [PHAsset]();
    var selectedImage: UIImage?
    var header: SelectPhotoHeader?
    
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell classes
        collectionView?.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier);
        collectionView?.register(SelectPhotoHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier);
        
        collectionView?.backgroundColor = .white;
       
        // configure nav buttons
        configureNavigationButton();
        
        // fetch photos
        fetchPhotos();
    }
    
    // MARK: - UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = view.frame.width;
        
        return CGSize(width: width, height: width);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 3) / 4
        
        return CGSize(width: width, height: width);
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1;
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeader;
        
        self.header = header;
        
        if let selectedImage = self.selectedImage
        {
            
            // index selected image
            if let index = self.images.index(of: selectedImage)
            {
                // asset associated with selected image
                let selectedAsset = self.assets[index];
                
                let imageManager = PHImageManager.default();
                let targetSize = CGSize(width: 600, height: 600);
                
                // request image
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    
                    header.photoImageView.image = image;
                }
            }
            
        }
        
        return header;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell;
        
        cell.photoImageView.image = images[indexPath.row];
        
        return cell;
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        self.selectedImage = images[indexPath.row];
        self.collectionView?.reloadData();
        
        let indexPath = IndexPath(item: 0, section: 0);
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    // MARK: - Handlers
    
    @objc
    func handleCancel()
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc
    func handleNext()
    {
        let uploadPostVC = UploadPostVC();
        uploadPostVC.selectedImage = header?.photoImageView.image;
        navigationController?.pushViewController(uploadPostVC, animated: true);
    }
    
    func configureNavigationButton()
    {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel));
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext));
    }
    
    // MARK: - API
    
    func getAssetFetchOptions() -> PHFetchOptions
    {
        let options = PHFetchOptions()
        
        // fetch limit
        options.fetchLimit = 30;
        
        // sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false);
        
        options.sortDescriptors = [sortDescriptor];
        
        return options;
    }
    
    func fetchPhotos()
    {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions());
     
        // fetch images on background thread
        DispatchQueue.global(qos: .background).async {
            
            // enumerate objects
            allPhotos.enumerateObjects { (asset, count, stop) in
            
                print(" Count is \(count)");
                
                let imageManager = PHImageManager.default();
                let targetSize = CGSize(width: 200, height: 200);
                let options = PHImageRequestOptions();
                options.isSynchronous = true;
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    if let image = image
                    {
                        // append image to data source
                        self.images.append(image);
                        
                        // append asset to data source
                        self.assets.append(asset);
                        
                        // set selected image with first image
                        if self.selectedImage == nil
                        {
                            self.selectedImage = image;
                        }
                        
                        // reload collection view with images once count has completed
                        if count == allPhotos.count - 1
                        {
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData();
                            }
                        }
                        
                    }
                    
                }
            }
            
        }
    }
}
