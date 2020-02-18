//
//  File.swift
//  InstagramClone
//
//  Created by 배상렬 on 2020/02/18.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuserIdentifier = "MessageCell"

class MessagesController: UITableViewController
{
    
    // MARK: - Properties
    
    // MARK: - Init
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell classes
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuserIdentifier);
        
        // configure navigation bar
        configureNavigationBar();
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! MessageCell;
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Handlers
    func configureNavigationBar()
    {
        navigationItem.title = "Messages";
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage));
    }
    
    @objc
    func handleNewMessage()
    {
        
    }
}
