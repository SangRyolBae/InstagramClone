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
    
    var messages = [Message]();
    var messageDictionary = [String: Message]();
    
    // MARK: - Init
    override func viewDidLoad()
    {
        super.viewDidLoad();
        
        // register cell classes
        tableView.register(MessageCell.self, forCellReuseIdentifier: reuserIdentifier);
        
        // configure navigation bar
        configureNavigationBar();
        
        fetchMessages();
    }
    
    // MARK: - UITableView
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuserIdentifier, for: indexPath) as! MessageCell;
        
        cell.message = messages[indexPath.row];
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row];
        let chatPartnerId = message.getChatPartnerId();
        
        Database.fetchUser(with: chatPartnerId) { (user) in
            self.showChatController(forUser: user);
        }
    }
    
    // MARK: - Handlers
    func configureNavigationBar()
    {
        navigationItem.title = "Messages";
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage));
    }
    
    func showChatController(forUser user: User)
    {
        let chatController = ChatController(collectionViewLayout: UICollectionViewFlowLayout());
        chatController.user = user;
        navigationController?.pushViewController(chatController, animated: true);
    }
    
    @objc
    func handleNewMessage()
    {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self;
        let navigationController = UINavigationController(rootViewController: newMessageController);
        self.present(navigationController, animated: true, completion: nil);
        
    }
    
    // MARK: - API
    func fetchMessages()
    {
        
        guard let currentUid = Auth.auth().currentUser?.uid else {return};
        
        self.messages.removeAll()
        self.messageDictionary.removeAll();
        self.tableView?.reloadData();

        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { (snapshot) in

            let uid = snapshot.key;

            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { (snapshot) in

                let messageId = snapshot.key;

                self.fetchMessage(withMessageId: messageId);
            }

        }
    }
    
    func fetchMessage(withMessageId messageId: String)
    {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else {return};
            
            let message = Message(dictionary: dictionary);
            
            let chatPartnerId = message.getChatPartnerId();
            self.messageDictionary[chatPartnerId] = message;
            self.messages = Array(self.messageDictionary.values);
            
            self.tableView?.reloadData();
        }
    }
    
}
