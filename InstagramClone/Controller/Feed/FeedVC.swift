//
//  FeedVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class FeedVC: UICollectionViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure Logout
        configureLogoutButton();
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    func configureLogoutButton()
    {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.navigationItem.title = "Feed";
    }
    
   
    // MARK: - Handlers
       
       @objc
          func handleLogout()
          {
              // declare alert controller
              let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
              
              // add alert log out action
              alertController.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
                  
                  do {
                      
                      // attempt sign out
                      try Auth.auth().signOut();
                      
                      // present login controller
                      let loginVC = LoginVC();
                      let navController = UINavigationController(rootViewController: loginVC);
                      self.present(navController, animated: true, completion: nil);
                      
                      print( "Successfully logged user out");
                      
                  }catch {
                      
                      print("Failed to sign out");
                      
                  }
              }))
              
              // add cancel action
              alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
              
              present(alertController, animated: true, completion: nil);
          }
    
}
