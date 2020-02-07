//
//  LoginVC.swift
//  InstagramClone
//
//  Created by 배상렬 on 06/02/2020.
//  Copyright © 2020 BaeSangRyol. All rights reserved.
//

import UIKit
import Firebase

class LoginVC: UIViewController
{
    let logoContainerView :UIView = {
        let view = UIView();
        let logoImageView = UIImageView(image: #imageLiteral(resourceName: "Instagram_logo_white"));
        logoImageView.contentMode = .scaleAspectFit;
        view.addSubview(logoImageView);
        
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50);
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true;
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true;
        view.backgroundColor = UIColor(displayP3Red: 0, green: 120/255, blue: 175/255, alpha: 1);
        return view;
    }();
    
    let emailTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Email";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged);
        return tf;
    }();
    
    let passwordTextField: UITextField = {
        let tf = UITextField();
        tf.placeholder = "Password";
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03);
        tf.borderStyle = .roundedRect;
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged);
        tf.isSecureTextEntry = true;
        return tf;
    }();
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system);
        button.setTitle("Login", for: .normal);
        button.setTitleColor(.white, for: .normal);
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
        button.layer.cornerRadius = 5;
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside);
        button.isEnabled = false;
        return button;
    }();
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system);
        
        let attributesTitle =  [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray];
        let attributedTitle = NSMutableAttributedString(string: "Don't have an account?    ", attributes: attributesTitle );
        
        let attributesSignUp = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)];
        let attributedSignUp = NSAttributedString(string: "Sign Up", attributes: attributesSignUp );
        
        attributedTitle.append(attributedSignUp);
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside);
        button.setAttributedTitle(attributedTitle, for: .normal);
        
        return button;
        
    }();
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        //background color
        view.backgroundColor = .white;
        
        // hide navigation bar
        navigationController?.navigationBar.isHidden = true;
        
        print("View did load!!");
        
        view.addSubview(logoContainerView);
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150);
        
        configureViewComponents();
        
        view.addSubview(dontHaveAccountButton);
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50);
    }
    
    //
    // View Component 셋팅
    func configureViewComponents()
    {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton]);
        
        stackView.axis = .vertical;
        stackView.spacing = 10;
        stackView.distribution = .fillEqually;
        
        view.addSubview(stackView);
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140);
        
    }
    
    @objc
    func handleShowSignUp()
    {
        print("Handle show sign up here..");
        
        let signUpVC = SignUpVC();
        
        navigationController?.pushViewController(signUpVC, animated: true);
    }
    
    @objc
    func handleLogin()
    {
        print("Handle Login");
        
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text else
        {
            return;
        }
        
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            
            // handle error
            if let error = error {
                print( "Unable to sign user in with error", error.localizedDescription);
                return;
            }
            
            // handle success
            print("Successfully signed user in");
            
            guard let mainTabVC = UIApplication.shared.keyWindow?.rootViewController as? MainTabVC else {return};
            
            // configure view controllers in maintabvc
            mainTabVC.configureViewControllers();
            
            // dismiss login controller
            self.dismiss(animated: true, completion: nil);
        }
        
    }
    
    @objc
    func formValidation()
    {
        guard
            emailTextField.hasText,
            passwordTextField.hasText else {
                
                loginButton.isEnabled = false;
                loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1);
                return;
        }
        
        // handle case for condition were met
        loginButton.isEnabled = true;
        loginButton.backgroundColor = UIColor(displayP3Red: 17/255, green: 154/255, blue: 237/255, alpha: 1);
    }
}
