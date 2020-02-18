//
//  MainTabVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class MainTabVC: UITabBarController, UITabBarControllerDelegate
{
    // MARK: - Properties
    
    let dot = UIView();
    var notificationIds = [String]();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // delegate
        self.delegate = self;
       
        // configure view controller
        configureViewControllers();
        
        // configure notification dot
        configureNotificationDot();
        
        // observe notifications
        observeNotifications();
        
        // user validation
        checkIfUserIsLoggedIn();
    }
    
    func configureViewControllers()
    {
        // home feed controller
        let feedVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: FeedVC(collectionViewLayout: UICollectionViewFlowLayout()));
        
        // search feed controller
        let searchVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchVC());
        
        // select image controller
        //let uploadPostVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostVC());
        let selectImageVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: SelectImageVC());
        
        // notification controller
        let notificationVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsVC());
        
        // profile controller
        let userProfileVC = constructNavController(unselectedImage: #imageLiteral(resourceName: "profile_selected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout()));
        
        // view controller to be added to tab controller
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, userProfileVC];
        
        // tab bar tint color
        tabBar.tintColor = .black;
    }
    
    // construct navigation controllers
    func constructNavController(unselectedImage:UIImage, selectedImage:UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController
    {
        
        let navController = UINavigationController(rootViewController: rootViewController);
        navController.tabBarItem.image = unselectedImage;
        navController.tabBarItem.selectedImage = selectedImage;
        navController.navigationBar.tintColor = .black;
        
        return navController;
    
    }
    
    func configureNotificationDot()
    {
        
        if UIDevice().userInterfaceIdiom == .phone
        {
            let tabBarHeight = tabBar.frame.height;
            
            if UIScreen.main.nativeBounds.height == 2436
            {
                // configure dot for iphone x
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6);
            }else
            {
                // configure dot for other phone models
                dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - 16, width: 6, height: 6);
            }
            
            // create dot
            dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2);
            dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1);
            dot.layer.cornerRadius = dot.frame.width / 2
            
            self.view.addSubview(dot);
            
            dot.isHidden = true;
        }
        
    }
    
    // MARK: - UITabBar
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
    
        let index = viewControllers?.index(of: viewController);
        
        if 2 == index
        {
            let selectImageVC = SelectImageVC(collectionViewLayout: UICollectionViewFlowLayout());
            let navController = UINavigationController(rootViewController: selectImageVC);
            navController.navigationBar.tintColor = .black
            self.present(navController, animated: true, completion: nil);
            
            return false;
        } else if index == 3
        {
            dot.isHidden = true;
            return true;
        }

        return true;
    }
    
    func checkIfUserIsLoggedIn()
    {
        if Auth.auth().currentUser == nil
        {
            DispatchQueue.main.async {
                
                // present login controller
                
                let loginVC = LoginVC();
                let navController = UINavigationController(rootViewController: loginVC);
                self.present(navController, animated: true, completion: nil);
                
            }
            return;
        }
    }
    
    func observeNotifications()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        self.notificationIds.removeAll();
        
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let allObject = snapshot.children.allObjects as? [DataSnapshot] else {return}
            
            allObject.forEach { (snpshot) in
                
                let notificationId = snapshot.key;
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value) { (snapshot) in
                    
                    guard let checked = snapshot.value as? Int else {return};
                    
                    if checked == 0
                    {
                        self.dot.isHidden = false;
                    }else
                    {
                        self.dot.isHidden = true;
                    }
                    
                }
                
            }
            
        }
    }
    
    

}
