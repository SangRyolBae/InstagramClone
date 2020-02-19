//
//  NewMessageController.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/19.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuserIdentifier = "NewMessageCell"

class NewMessageController: UITableViewController
{
    // MARK: - Properties
    var users = [User]();
    var messagesController: MessagesController?
    
    // MARK: - Init
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell classes
        tableView.register(NewMessageCell.self, forCellReuseIdentifier: reuserIdentifier);
        
        // configure navigation bar
        configureNavigationBar();
        
        // fetch users
        fetchUsers();
        
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! NewMessageCell;
        
        cell.user = users[indexPath.row];
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.dismiss(animated: true) {
            
            let user = self.users[indexPath.row];
            
            self.messagesController?.showChatController(forUser: user);
        }
    }
    
    // MARK: - Handlers
    
    func configureNavigationBar()
    {
        navigationItem.title = "New Message";
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel));
        navigationItem.leftBarButtonItem?.tintColor = .black;
    }
    
    @objc
    func handleCancel()
    {
        dismiss(animated: true, completion: nil);
    }
    
    // MARK: - APIs
    func fetchUsers()
    {
        USER_REF.observe(.childAdded) { (snapshot) in
            let uid = snapshot.key;
            
            if uid != Auth.auth().currentUser?.uid
            {
                Database.fetchUser(with: uid) { (user) in
                    
                    self.users.append(user);
                    
                    self.tableView?.reloadData();
   
                }
            }
        }
    }
    
}
