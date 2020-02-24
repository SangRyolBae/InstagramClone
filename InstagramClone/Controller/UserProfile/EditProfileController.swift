//
//  EditProfileController.swift
//  InstagramClone
//
//  Created by 배상렬 on 10/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class EditProfileController: UIViewController
{
    
    // MARK: - Properties
    let profileImageView: CustomImageView = {
        let iv = CustomImageView();
        iv.contentMode = .scaleAspectFill;
        iv.clipsToBounds = true;
        iv.backgroundColor = .lightGray;
        return iv;
    }();
    
    let changePhotoButton: UIButton = {
        
        let button = UIButton(type: .system);
        button.setTitle("Change Profile Photo", for: .normal);
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14);
        button.addTarget(self, action: #selector(handleChangeProfilePhoto), for: .touchUpInside);
        return button;
        
    }();
    
    let separatorView: UIView = {
       
        let view = UIView()
        view.backgroundColor = .lightGray;
        return view;
        
    }()
    
    let usernameTextField: UITextField = {
        
        let tf = UITextField();
        tf.textAlignment = .left;
        tf.borderStyle = .none;
        return tf;
        
    }();
    
    let fullnameTextField: UITextField = {
        let tf = UITextField();
        tf.textAlignment = .left;
        tf.borderStyle = .none;
        tf.isUserInteractionEnabled = false;
        return tf;
    }()
        
    let usernameLabel: UILabel = {
        
        let label = UILabel();
        label.text = "User name"
        label.font = UIFont.systemFont(ofSize: 16);
        return label;
        
    }();
    
    let fullnameLabel: UILabel = {
        
        let label = UILabel();
        label.text = "Full name"
        label.font = UIFont.systemFont(ofSize: 16);
        return label;
        
    }();
        
    let usernameSeparatorView: UIView = {
       
        let view = UIView()
        view.backgroundColor = .lightGray;
        return view;
        
    }()
    
    let fullnameSeparatorView: UIView = {
       
        let view = UIView()
        view.backgroundColor = .lightGray;
        return view;
        
    }()
        
    // MARK: - var and let
    
    var user:User?
    var imageChanged = false;
    var usernameChanged = false;
    var userProfileController: UserProfileVC?
    var updatedUsername: String?
    
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigationBar();
        
        configureViewComponents();
        
        usernameTextField.delegate = self;
        
        loadUserData();
    }
    
    
    // MARK: - Handlers
    
    
    func configureNavigationBar()
    {
        
        navigationItem.title = "Edit Profile";
        
        navigationController?.navigationBar.tintColor = .black;
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel));
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleDone));
        
    }
    
    func configureViewComponents()
    {
        view.backgroundColor = .white;
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 150);
        
        let containerView = UIView(frame: frame);
        
        containerView.backgroundColor = UIColor.groupTableViewBackground;
        
        view.addSubview(containerView);
        
        containerView.addSubview(profileImageView);
        profileImageView.anchor(top: containerView.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80);
        profileImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true;
        profileImageView.layer.cornerRadius = 80 / 2
        
        containerView.addSubview(changePhotoButton);
        changePhotoButton.anchor(top: profileImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        changePhotoButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true;
        
        containerView.addSubview(separatorView)
        separatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5);
        
        // Full name
        view.addSubview(fullnameLabel);
        fullnameLabel.anchor(top: containerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
    
        view.addSubview(fullnameTextField);
        fullnameTextField.anchor(top: containerView.bottomAnchor, left: fullnameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0);
        
        view.addSubview(fullnameSeparatorView)
        fullnameSeparatorView.anchor(top: nil, left: fullnameTextField.leftAnchor, bottom: fullnameTextField.bottomAnchor, right: fullnameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: 0, height: 0.5);
        
        
        // Username
        view.addSubview(usernameLabel);
        usernameLabel.anchor(top: fullnameLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 0, height: 0);
        
        view.addSubview(usernameTextField);
        usernameTextField.anchor(top: fullnameLabel.bottomAnchor, left: usernameLabel.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: (view.frame.width / 1.6), height: 0);
        
        view.addSubview(usernameSeparatorView)
        usernameSeparatorView.anchor(top: nil, left: usernameTextField.leftAnchor, bottom: usernameTextField.bottomAnchor, right: usernameTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: -8, paddingRight: 0, width: 0, height: 0.5);
        
    }
    
    @objc
    func handleCancel()
    {
        self.dismiss(animated: true, completion: nil);
    }
    
    @objc
    func handleDone()
    {
        view.endEditing(true)
        
        if usernameChanged {
            updateUsername();
        }

        if imageChanged {
            updateProfileImage();
        }
    }
    
    @objc
    func handleChangeProfilePhoto()
    {
        let imagePickerController = UIImagePickerController();
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = true;
        
        present(imagePickerController, animated: true, completion: nil);
    }
    
    // MARK: - API

    func updateUsername()
    {
        
        guard let updatedUsername = self.updatedUsername else { return };
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        guard usernameChanged == true else {return};
        
        USER_REF.child(currentUid).child("username").setValue(updatedUsername) { (err, ref) in
            
            guard let userProfileController = self.userProfileController else { return };
            
            userProfileController.fetchCurrentUserData();
            
            self.dismiss(animated: true, completion: nil);
            
        }
        
        
    }
    
    func loadUserData()
    {
        
        guard let user = self.user else { return };
        
        profileImageView.loadImage(with: user.profileImageUrl);
        
        fullnameTextField.text = user.name;
        
        usernameTextField.text = user.username;
        
    }
    
    func updateProfileImage()
    {
        
        guard imageChanged == true else {return};
        guard let currentUid = Auth.auth().currentUser?.uid else { return };
        guard let user = self.user else { return };
        
        Storage.storage().reference(forURL: user.profileImageUrl).delete(completion: nil);
        
        let filename = NSUUID().uuidString;
        
        guard let updatedProfileImage = profileImageView.image else { return};
        
        guard let imageData = updatedProfileImage.jpegData(compressionQuality: 0.3) else { return };
        
        STORAGE_PROFILE_IMAGES_REF.child(filename).putData(imageData, metadata: nil) { (metadata, error) in
            
            if let error = error
            {
                print("Failed to upload image to storage with error: ", error.localizedDescription);
                return;
            }
 
            STORAGE_PROFILE_IMAGES_REF.child(filename).downloadURL { (downloadUrl, error) in
                
                guard let updatedProfileImageUrl = downloadUrl?.absoluteString else
                {
                    print("Profile image Url is nil");
                    return;
                }
            
                USER_REF.child(currentUid).child("profileImageUrl").setValue(updatedProfileImageUrl) { (err, ref) in
                    
                    guard let userProfileController = self.userProfileController else { return };
                    
                    userProfileController.fetchCurrentUserData();
                    
                    self.dismiss(animated: true, completion: nil);
                    
                }
            }
            
        }
        
    }
}

// MARK: - Edit Profile Controller

extension EditProfileController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            profileImageView.image = selectedImage;
            self.imageChanged = true;
        }
        
        dismiss(animated: true, completion: nil);
    }
}

extension EditProfileController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let user = self.user else { return }
        
        let trimmedString = usernameTextField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard user.username != trimmedString else {
            print("ERROR: You did not change you username")
            usernameChanged = false
            return
        }
        
        guard trimmedString != "" else {
            print("ERROR: Please enter a valid username")
            usernameChanged = false
            return
        }
        
        updatedUsername = trimmedString?.lowercased()
        usernameChanged = true
    }
}
