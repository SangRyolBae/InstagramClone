//
//  SearchVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell";

class SearchVC: UITableViewController
{
    // MARK: - Properties
    
    var users = [User]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // register cell classes
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier);
        
        // separator insets
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 64, bottom: 0, right: 0);
        
        // configure nav controller
        configureNavController();
        
        // fetch users
        fetchUsers();
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let user = users[indexPath.row];
        
        // create instance of user profile VC
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout());
        
        // passes user from searchVC to userProfileVC
        userProfileVC.userToLoadFromSearchVC = user;
        
        // push view controller
        navigationController?.pushViewController(userProfileVC, animated: true);
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell;
        
        cell.user = users[indexPath.row];
        
        return cell;
    }
    
    // MARK : - Handlers

    func configureNavController()
    {
        navigationItem.title = "Explore";
    }
    
    // MARK : - API
    
    func fetchUsers()
    {
        let usersDB = Database.database().reference().child("users");
        usersDB.observe(.childAdded) { (snapshot) in
        
            print("Result : ", snapshot);
            
            // uid
            let uid = snapshot.key
            
            // snapshot value cast as dictionary
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return };
            
            // construct user
            let user = User(uid: uid, dictionary: dictionary);
            
            // append user to data source
            self.users.append(user);
            
            // reload our table view
            self.tableView.reloadData();
        };
        
        
        
    }
    
}
