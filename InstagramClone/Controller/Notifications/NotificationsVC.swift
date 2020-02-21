//
//  NotificationsVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 07/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifer = "NotificationCell";

class NotificationsVC: UITableViewController, NotificationCellDelegate
{
    
    // MARK: - Properties
    
    var timer: Timer?
    var notifications = [Notification]();
    var currentKey: String?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // clear separator lines
        tableView.separatorColor = .clear
        
        // nav title
        navigationItem.title = "Notifications";
        
        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifer);
        
        // fetch notifications
        fetchNotifications();
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return notifications.count;
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        if notifications.count > 3
        {
            if indexPath.item == notifications.count - 1 {
                fetchNotifications();
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! NotificationCell;
       
        cell.delegate = self;
        
        cell.notification = notifications[indexPath.row];
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let notification = notifications[indexPath.row];
        
        print("User that sent notification is \(notification.user.username)");
        
        let userProfileVC = UserProfileVC(collectionViewLayout: UICollectionViewFlowLayout());
        userProfileVC.user = notification.user;
        navigationController?.pushViewController(userProfileVC, animated: true);
    }
    
    // MARK: - API
    func fetchNotifications()
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        if nil == currentKey
        {
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                
                //self.collectionView?.refreshControl?.endRefreshing();
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let notificationId = snapshot.key;
                    
                    self.fetchNotification(withNotificationId: notificationId, dataSnapshot: snapshot)
                    
                }
                
                self.currentKey = first.key;
            }
        }else
        {
            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 7).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {return };
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return};
                
                allObjects.forEach { (snapshot) in
                    
                    let notificationId = snapshot.key;
                
                    if notificationId != self.currentKey
                    {
                        self.fetchNotification(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                    
                }
                
                self.currentKey = first.key;
            }
        }
        
    }
    
    func fetchNotification(withNotificationId notificationId:String, dataSnapshot snapshot: DataSnapshot)
    {
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return};
        guard let uid = dictionary["uid"] as? String else {return};
        
        Database.fetchUser(with: uid) { (user) in
            
            // if notification is for post
            if let postId = dictionary["postId"] as? String
            {
                Database.fetchPost(with: postId) { (post) in
                    
                    let notification = Notification(user: user, post: post, dictionary: dictionary);
                    
                    self.notifications.append(notification);
                    self.handleReloadTable();
                }
            }
            else
            {
                let notification = Notification(user: user, dictionary: dictionary);
                
                self.notifications.append(notification);
                self.handleReloadTable();
            }
        }
        
        NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1);
    }
    
        
    // MARK: - Handlers
    func handleReloadTable()
    {
        self.timer?.invalidate();
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false);
        
    }
    
    @objc func handleSortNotifications()
    {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationData > notification2.creationData;
        }
        
        self.tableView.reloadData();
    }
    
    // MARK: - NotificationCellDelegate Protocol
    
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            
            // handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)
        } else {
            
            // handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)
        }
    }
    
    
    func handlePostTapped(for cell: NotificationCell)
    {
        guard let post = cell.notification?.post else {return};
        
        let feedController = FeedVC(collectionViewLayout: UICollectionViewFlowLayout());
        feedController.viewSinglePost = true;
        feedController.post = post;
        navigationController?.pushViewController(feedController, animated: true);
    }
}
