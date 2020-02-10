//
//  UserProfileVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileVC: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    var user: User?;
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier);
        
        // background color
        self.collectionView.backgroundColor = .white;
        
        // fetch user data
        fetchCurrentUserData();
        
    }

    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
         
        // declare header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader;
        
        // set the user in header
        let currentUid = Auth.auth().currentUser?.uid;
        let usersDB = Database.database().reference().child("users").child(currentUid!);
        usersDB.observeSingleEvent(of: .value) { (snapshot) in
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return };
            let uid = snapshot.key;
            let user = User(uid: uid, dictionary: dictionary);
            self.navigationItem.title = user.username;
            header.user = user;
        }
        
        // return header
        return header;
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    
    
    func fetchCurrentUserData()
    {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        
        print("Current user id is \(currentUid)");
        
        // User name Setting
        let usersDB = Database.database().reference().child("users").child(currentUid);
        usersDB.observeSingleEvent(of: .value) { (snapshot) in
            
            //guard let username = snapshot.value as? String else {return}
            
            //self.navigationItem.title = username;
            
            print(snapshot);
            
            let uid = snapshot.key;
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return };
            
            let user = User(uid: uid, dictionary: dictionary);
            
            print( "Username is \(user.username)");
            
            self.navigationItem.title = user.username;
            
            self.user = user;
            
            
        }
    }

}
