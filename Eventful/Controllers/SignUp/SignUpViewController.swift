//
//  SignUpViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import TextFieldEffects
import Firebase
import FirebaseStorage


class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedImageFromPicker: UIImage?
    // creates a signup UILabel
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setCellShadow()
        button.setImage(#imageLiteral(resourceName: "camblack").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
     plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    let nameTextField : HoshiTextField = {
        let nameText = HoshiTextField()
        nameText.placeholderColor = .black
        nameText.placeholder = "Username"
        nameText.placeholderFontScale = 0.85
        nameText.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        nameText.layer.borderColor = UIColor.lightGray.cgColor
        nameText.layer.borderWidth = 0
        nameText.borderStyle = .none
        nameText.borderInactiveColor = .black
        nameText.borderActiveColor = .black
        nameText.textColor = .black
        return nameText
    }()
    
    // creates a email UITextField to hold the email
    let emailTextField : HoshiTextField = {
        let emaiilText = HoshiTextField()
        emaiilText.placeholderColor = .black
        emaiilText.placeholderFontScale = 0.85
        emaiilText.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        emaiilText.placeholder = "Email"
        emaiilText.layer.borderColor = UIColor.lightGray.cgColor
        emaiilText.layer.borderWidth = 0
        emaiilText.borderStyle = .none
        emaiilText.borderInactiveColor = .black
        emaiilText.borderActiveColor = .black
        emaiilText.textColor = .black
        return emaiilText
    }()
    
    //creates a password UItextield
    let passwordTextField : HoshiTextField = {
        let passwordText = HoshiTextField()
        passwordText.placeholderColor = .black
        passwordText.placeholderFontScale = 0.85
        passwordText.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        passwordText.placeholder = "Password"
        passwordText.layer.borderColor = UIColor.lightGray.cgColor
        passwordText.layer.borderWidth = 0
        passwordText.isSecureTextEntry = true
        passwordText.borderStyle = .none
        passwordText.borderInactiveColor = .black
        passwordText.borderActiveColor = .black
        passwordText.textColor = .black
        return passwordText
    }()
    
    //creates a confirm password UItextfield
    let confirmPasswordTextField : HoshiTextField = {
        let confirmPasswordText = HoshiTextField()
        confirmPasswordText.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        confirmPasswordText.placeholderFontScale = 0.85
        confirmPasswordText.placeholderColor = .black
        confirmPasswordText.placeholder = "Confirm Password"
        confirmPasswordText.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordText.layer.borderWidth = 0
        confirmPasswordText.isSecureTextEntry = true
        confirmPasswordText.borderStyle = .none
        confirmPasswordText.borderInactiveColor = .black
        confirmPasswordText.borderActiveColor = .black
        confirmPasswordText.textColor = .black
        return confirmPasswordText
    }()
    
    // creates a UIButton that will sign up the user
    let signupButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.setCellShadow()
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
    }()
    
    // will handle the  sign up of a user
    @objc func handleSignUp(){
        print("entered sign up")
        // first we cant to take sure that all of the fields are filled
        // will take the user selected image and load it to firebase
        let imageName = NSUUID().uuidString
        guard let username = self.nameTextField.text?.lowercased(),
            let confirmPassword = self.confirmPasswordTextField.text,
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            !username.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            !confirmPassword.isEmpty
            else {
                let alertController = UIAlertController(title: "", message: "Please Make Sure You Have Filled in All Required Fields Before Pressing Sign Up", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
                return
        }
        if self.validateEmail(enteredEmail:email) != true{
            let alertController = UIAlertController(title: "Error", message: "Please Enter A Valid Email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // will make sure user is validated before it even tries to create user
        // will make sure the password and confirm password textfields have the same value if so it will print an error
        if self.passwordTextField.text != self.confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Error", message: "Passwords Don't Match", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        if selectedImageFromPicker == nil {
            let alertController = UIAlertController(title: "Error", message: "Select a Profile Picrue", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        //create a reference to the sotrage database in firebase
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).PNG")
        //following function does the work of putting it into firebase
        //notice I also set the value of profilepic oo it can be saved in the updated user instance in the database
        if let userImage = selectedImageFromPicker,let uploadData = UIImageJPEGRepresentation(userImage, 0.1){
            //will ensure that each user has a unique username
            AuthService.checkUserNameAlreadyExist(newUserName: username, completion: { [unowned self] (isUnique) in
                if isUnique {
                    //username exists so user has to try again
                    self.showAlertThatLoginAlreadyExists()
                }else{
                    //username does not exist and will authenticate user
                    AuthService.createUser(controller: self, email: email, password: password) {[unowned self] (authUser) in
                       
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error ?? "")
                                return
                            }
                            // Firebase 5 Update: Must now retrieve downloadURL
                            storageRef.downloadURL(completion: { (downloadURL, err) in
                                guard let profileImageUrl = downloadURL?.absoluteString else { return }
                                 print("Successfully uploaded profile image:", profileImageUrl)
                                if let user = authUser {
                                    UserService.create( user, username: username, profilePic: profileImageUrl, isPrivate: false, completion: { (user) in
                                        
                                        if let user = user {
                                                    User.setCurrent(user, writeToUserDefaults: true)
                                            self.finishSigningUp()
                                        }

                                    })
                                }
                                
                            
                            
                            })
                            
                        })
                    }
                }
            })
        }
       // self.present(alertController, animated: true, completion: nil)

    }
    
    private func showAlertThatLoginAlreadyExists() {
        let alert = UIAlertController(title: "Registration failed!",
                                      message: "Username already exists.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func finishSigningUp() {
        let homeController = HomeViewController()
        //should change the root view controller to the homecontroller when done signing up
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
    }
    
    
    // will validate email entry so user can not enter false text
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }

    
    
    // will create a cancel button so users can go back to login screen if they actually want to log in
    // Buton setup as well as cancel will be in this code block
    let cancelButton : UIButton = {
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cancel.setTitleColor(.black, for: .normal)
        cancel.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return cancel
    }()
    
    @objc func handleCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }

 
    
  

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
       setupVC()
    }
    
    @objc func setupVC(){
        view.backgroundColor = .white
       self.addTapGestures()
        self.addScrollView()
     //   self.addBottomMostItems()
        
    }
    
    @objc func addTapGestures(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    


    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    
    //MARK:- View Builder
    fileprivate var contentScrollView:UIScrollView!
    fileprivate var activeTextField:UITextField?
    
    //creatas a UILabel
    let signInLabel: UILabel = {
        let signUp = UILabel()
        signUp.textColor = UIColor.black
        signUp.font = UIFont(name: "Futura", size: 13)
        signUp.text = "Already Have An Account?"
        return signUp
    }()
    
    //will create the signup button
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = UIFont(name: "Futura", size: 13)
        button.setTitleColor(UIColor.rgb(red: 45, green: 162, blue: 232), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    fileprivate func addScrollView() {
       
        self.plusPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(plusPhotoButton)
        plusPhotoButton.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.top).inset(65)
            make.height.width.equalTo(100)
            make.centerX.equalTo(view.snp.centerX)
        }
//        //username
        self.nameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTextField.delegate = self
        view.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(plusPhotoButton.snp.top).offset(130)
            make.height.equalTo(49.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        //email
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.emailTextField.delegate = self
        view.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.top).offset(60)
            make.height.equalTo(49.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
//        //pw
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.delegate = self
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(emailTextField.snp.top).offset(60)
            make.height.equalTo(49.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
//
//        //confirm pw
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.confirmPasswordTextField.delegate = self
        view.addSubview(confirmPasswordTextField)
        confirmPasswordTextField.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTextField.snp.top).offset(60)
            make.height.equalTo(49.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        self.signupButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signupButton)
        signupButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPasswordTextField.snp.top).offset(90)
//            make.height.equalTo(47.5)
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        self.signInLabel.translatesAutoresizingMaskIntoConstraints = false
        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(arrangedSubviews: [signInLabel,signInButton])
        stackView.axis = .horizontal
        stackView.spacing = 5.0
        view.addSubview(stackView)
        stackView.snp.makeConstraints({ (make) in
            make.bottom.equalTo(signupButton.snp.bottom).offset(35)
            make.centerX.equalTo(view.snp.centerX)
        })

    }
    
 
    

    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

