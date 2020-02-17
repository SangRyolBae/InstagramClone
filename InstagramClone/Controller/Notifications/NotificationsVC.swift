//
//  NotificationsVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit

private let reuseIdentifer = "NotificationCell";

class NotificationsVC: UITableViewController {

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // clear separator lines
        tableView.separatorColor = .clear
        
        // nav title
        navigationItem.title = "Notifications";
        
        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifer);
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! NotificationCell;
       
        return cell;
    }
}
