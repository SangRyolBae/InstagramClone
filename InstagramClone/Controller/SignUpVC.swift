//
//  SignUpVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 06/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController
{
    
    let plusPhotoBtn: UIButton = {
    
        let button = UIButton(type: .system);
        button.setImage( #imageLiteral(resourceName: "plus_photo").withRenderingMode(.alwaysOriginal), for: .normal);
        return button;
        
    }();
    
    let emailTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Email";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for:.editingChanged);
        return tf;
    }();
    
    let fullNameTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Full Name";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf;
    }();
    
    let usernameTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Username";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf;
    }();
    
    let passwordTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Password";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true;
        tf.addTarget(self, action: #selector(formValidation), for:.editingChanged);
        return tf;
    }();
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system);
        button.setTitle("Sign Up", for: .normal);
        button.setTitleColor(.white, for: .normal);
        button.backgroundColor = UIColor(displayP3Red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
        button.layer.cornerRadius = 5;
        button.isEnabled = false;
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside);
        
        return button;
    }();
    
    let alreadyHaveAccountButton: UIButton = {
           let button = UIButton(type: .system);
           
           let attributesTitle =  [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray];
           let attributedTitle = NSMutableAttributedString(string: "Akready have an account?    ", attributes: attributesTitle );
           
           let attributesSignUp = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)];
           let attributedSignUp = NSAttributedString(string: "Sign In", attributes: attributesSignUp );
           
           attributedTitle.append(attributedSignUp);
           
           button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside);
           button.setAttributedTitle(attributedTitle, for: .normal);
           
           return button;
           
       }();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // background color
        view.backgroundColor = .white;

        view.addSubview(plusPhotoBtn);
        plusPhotoBtn.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140);
        plusPhotoBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true;
        
        configureViewComponents();
        
        view.addSubview(alreadyHaveAccountButton);
        alreadyHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50);
        
    }
    
    func configureViewComponents()
    {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton]);
        
        stackView.axis = .vertical;
        stackView.spacing = 10;
        stackView.distribution = .fillEqually;
        
        view.addSubview(stackView);
        
        stackView.anchor(top: plusPhotoBtn.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240);
        
    }
    
    @objc
    func handleShowLogin()
    {
        print("Goto Show Login");
        
        navigationController?.popViewController(animated: true);
        
    }
    
    @objc
    func handleSignUp()
    {
    
        print("Sign Up ");
        
        guard let email = emailTextField.text else {return};
        guard let password = passwordTextField.text else {return};
        
        print("Email is \(email) and password is \(password)");
        
        Auth.auth().createUser(withEmail: email, password: password) {(user, error) in
            
            // handle error
            if let error = error {
                print("Failed to create user with error: " , error.localizedDescription);
                return;
            }
            
            // success
            print("Successfully created user with Firebase");
            
            
        }
        //Auth.auth().createUser(withEmail)
        
    }
    
    @objc
    func formValidation()
    {
        guard
            emailTextField.hasText,
            passwordTextField.hasText else {
                
                signUpButton.isEnabled = false;
                signUpButton.backgroundColor = UIColor(displayP3Red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
                
                return;
        };
        
        signUpButton.isEnabled = true;
        signUpButton.backgroundColor = UIColor(displayP3Red: 17/255, green: 154/255, blue: 237/255, alpha: 1);
    }
}
