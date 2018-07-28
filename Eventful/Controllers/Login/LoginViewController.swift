//
//  LoginViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/24/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import TextFieldEffects

protocol LoginViewControllerDelegate: class {
    func finishLoggingIn()
}



class LoginViewController: UIViewController , LoginViewControllerDelegate {
    //Login Controller Instance
   // var loginController: LoginViewController?
    weak var delegate : LoginViewControllerDelegate?
    let signUpTransition = SignUpViewController()
    let forgotPasswordTransition = ForgotPasswordViewController()
    fileprivate var activeTextField:UITextField?
    lazy var logoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.setCellShadow()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logoWithWords")
        return iv
    }()
    
    
    // creates a UITextField
    
    let emailTextField : HoshiTextField = {
        let textField = HoshiTextField()
//        textField.placeholderColor = UIColor.logoColor
        textField.placeholderColor = UIColor.black
        textField.placeholder = "Email"
        textField.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        textField.placeholderFontScale = 0.85
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.borderStyle = .none
        textField.borderInactiveColor = UIColor.black
        textField.borderActiveColor = UIColor.black
        textField.textColor = .black
        return textField
    }()

    // creates a UITextField
    let passwordTextField : HoshiTextField = {
        let textField = HoshiTextField()
//        textField.placeholderColor = UIColor.logoColor
        textField.placeholderColor = UIColor.black
        textField.placeholder = "Password"
        textField.placeholderFontScale = 0.85
        textField.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.borderInactiveColor = UIColor.black
        textField.borderActiveColor = UIColor.black
        textField.textColor = .black
        return textField
    }()
    // creates a UIButton and transitions to a different screen after button is selected
    
    lazy var loginButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setCellShadow()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
    }()
    
    @objc func handleLogin(){
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and a a password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            SVProgressHUD.show(withStatus: "Logging in...")
            AuthService.signIn(controller: self, email: emailTextField.text!, password: passwordTextField.text!) { [unowned self] (user) in
                guard user != nil else {
                    // look back here
           
                    print("error: FiRuser dees not exist")
                    return
                }
              //  print("user is signed in")
                UserService.show(forUID: (user?.uid)!) {[unowned self] (user) in
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                        self.finishLoggingIn()
                }
                    else {
                        print("error: User does not exist!")
                        return
                    }
                }
            }
        }

    }
    
    func finishLoggingIn() {
       // print("Finish logging in from LoginController")
        let homeController = HomeViewController()
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
    }
    
    //creatas a UILabel
    let signUpLabel: UILabel = {
        let signUp = UILabel()
        signUp.text = "Don't Have An Account?"
        signUp.textColor = UIColor.black
        signUp.font = UIFont(name: "Futura", size: 13)
        return signUp
    }()
    
    //will create the signup button
    let signUpButton: UIButton = {
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "Futura", size: 13)
        signUpButton.setTitleColor(UIColor.rgb(red: 45, green: 162, blue: 232), for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUpTransition), for: .touchUpInside)
        return signUpButton
    }()
    

    lazy var forgotPasswordButton: UIButton = {
        let forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        forgotPasswordButton.setTitleColor(UIColor.black, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPasswordTransition), for: .touchUpInside)
        return forgotPasswordButton
    }()
    
    override func viewDidLoad() {
        // Every view that I add is from the top down imagine a chandeler that you are just hanging things from
        print("app begun")
        super.viewDidLoad()
        // will add each of the screen elements to the current view
        self.view.backgroundColor = UIColor.white

        
       // self.view.backgroundColor = UIColor(r: 255, g: 255 , b: 255)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        setupLoginScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.observeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.removeObserveKeyboardNotifications()
    }
    
    var stackView: UIStackView?
    var stackView2: UIStackView?
    fileprivate func setupLoginScreen(){
        self.view.addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(82)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
        }
        
       
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.emailTextField.delegate = self
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.centerY.equalTo(view.safeAreaLayoutGuide.snp.centerY).offset(40)
            make.height.equalTo(47.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.delegate = self
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.top).offset(50)
            make.height.equalTo(47.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }

        self.loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.top).offset(80)
            //            make.height.equalTo(47.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }


        self.view.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { (make) in
            make.top.equalTo(loginButton.snp.bottom).offset(5)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
        }
        stackView2 = UIStackView(arrangedSubviews: [ signUpLabel, signUpButton])
        stackView2?.axis = .horizontal
        stackView2?.spacing = 5.0
        self.view.addSubview(stackView2!)
        stackView2?.snp.makeConstraints({ (make) in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(5)
            make.centerX.equalTo(view.safeAreaLayoutGuide.snp.centerX)
        })


       NotificationCenter.default.post(name: heartAttackNotificationName, object: nil)
    }
 
    
  
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    //will open a new ViewController when forgot password button is pressed
    @objc func handleForgotPasswordTransition(){
        print("forgot password tapped")
        present(self.forgotPasswordTransition, animated: true, completion: nil)
    }
    
    // will open a new ViewController When login button is selected
    @objc func handleSignUpTransition(){
        present(self.signUpTransition, animated: true, completion: nil)
    }
    
    // Will move the UI Up on login Screen when keyboard appears
    
//    fileprivate func  observeKeyboardNotifications(){
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
//
//    }
    
    fileprivate func  removeObserveKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
//
//    //will properly show keyboard
//    @objc func keyboardWillShow(notification:NSNotification){
//
//        var userInfo = notification.userInfo!
//        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
//        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
//
//        var contentInset:UIEdgeInsets = self.contentScrollView.contentInset
//        contentInset.bottom = keyboardFrame.size.height
//        contentScrollView.contentInset = contentInset
//    }
//
//    //will properly hide keyboard
//    @objc func keyboardWillHide(notification:NSNotification){
//
//        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
//        contentScrollView.contentInset = contentInset
//    }
    
    
}


extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}



extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

