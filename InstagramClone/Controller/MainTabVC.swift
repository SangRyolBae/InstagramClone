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

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // delegate
        self.delegate = self;
       
        // configure view controller
        configureViewControllers();
        
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

}
