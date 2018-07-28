//
//  AuthService.swift
//  Eventful
//
//  Created by Shawn Miller on 7/26/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD
import Firebase
import FirebaseDatabase
import FirebaseMessaging
import FirebaseStorage

struct AuthService {
    
    //will sign in an authenticated user
    static func signIn(controller : UIViewController, email: String, password: String, completion: @escaping (FIRUser?) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                loginErrors(error: error!, controller: controller)
                return completion(nil)
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            UserService.updateDeviceToken(deviceToken: appDelegate.strDeviceToken, userId: (Auth.auth().currentUser?.uid)!)
            return completion(user?.user)
        }
    }
    
    
    // Creates an authenticated user on Firebase
    static func createUser(controller : UIViewController, email: String, password: String, completion: @escaping (FIRUser?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
               signUpErrors(error: error, controller: controller)
                return completion(nil)
            }
            SVProgressHUD.show(withStatus: "Creating Account....")
            return completion(user?.user)
        }
    }
    
    //will signout an authenticated user
    
    
    static func presentLogOut(viewController : UIViewController){
        let alertController = UIAlertController(title: "Are You Sure You Want To Log Out?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let logoutAction = UIAlertAction(title: "Log Out", style: .default){_ in
        logUserOut()
                    }
        alertController.addAction(logoutAction)
    
        viewController.present(alertController, animated: true)
    }
    
    
    static func logUserOut(){
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            assertionFailure("Error signing out: \(error.localizedDescription)")
        }

    }
    
    //will allow user to return to login controller after they logout
    
    static func authListener(viewController view : UIViewController) -> AuthStateDidChangeListenerHandle {
        let authHandle = Auth.auth().addStateDidChangeListener() { (auth, user) in
            guard user == nil else { return }
            
            let loginViewController = LoginViewController()
            view.view.window?.rootViewController = loginViewController
            view.view.window?.makeKeyAndVisible()
        }
        return authHandle
    }
    
    //use this to confirm user has logged out
    static func removeAuthListener(authHandle : AuthStateDidChangeListenerHandle?){
        if let authHandle = authHandle {
            Auth.auth().removeStateDidChangeListener(authHandle)
        }
    }
    
    static func resetUserPassword(controller: UIViewController,for email: String?, completion: @escaping (Bool) -> Void){
        //send email for user to reset password
        if let userEmail = email {
            Auth.auth().sendPasswordReset(withEmail: userEmail) { (error) in
                if let errors = error {
                    print(errors)
                    //show some error in regards to password reset
                    resetErrors(error: error!, controller: controller)
                    return completion(false)
                }
                //success
                print("Sent password reset to \(String(describing: email))")
                completion(true)
                //show completion of password reset action
                
            }
        }
  
        
    }
    
    //will ensure that a user has a unique username
    static func checkUserNameAlreadyExist(newUserName: String, completion: @escaping(Bool) -> Void) {
        // print(newUserName)
        let ref = Database.database().reference()
        ref.child("users").queryOrdered(byChild: "username").queryEqual(toValue: newUserName)
            .observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                // print(snapshot)
                if snapshot.exists() {
                    completion(true)
                }
                else {
                    completion(false)
                }
            })
    }
    
    
    private static func loginErrors(error : Error, controller : UIViewController){
        switch (error.localizedDescription) {
        case "The email address is badly formatted.":
            let invalidEmailAlert = UIAlertController(title: "Invalid Email", message:
                "It seems like you have put in an invalid email.", preferredStyle: UIAlertControllerStyle.alert)
            invalidEmailAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(invalidEmailAlert, animated: true, completion: nil)
            break;
        case "The password is invalid or the user does not have a password.":
            let wrongPasswordAlert = UIAlertController(title: "Wrong Password", message:
                "It seems like you have entered the wrong password.", preferredStyle: UIAlertControllerStyle.alert)
            wrongPasswordAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(wrongPasswordAlert, animated: true, completion: nil)
            break;
        case "There is no user record corresponding to this identifier. The user may have been deleted.":
            let wrongPasswordAlert = UIAlertController(title: "No Account Found", message:
                "We couldn't find an account that corresponds to that email. Do you want to create an account?", preferredStyle: UIAlertControllerStyle.alert)
            wrongPasswordAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(wrongPasswordAlert, animated: true, completion: nil)
            break;
        default:
            let loginFailedAlert = UIAlertController(title: "Error Logging In", message:
                "There was an error logging you in. Please try again soon.", preferredStyle: UIAlertControllerStyle.alert)
            loginFailedAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(loginFailedAlert, animated: true, completion: nil)
            break;
        }
    }
    
    
    private static func signUpErrors(error: Error, controller: UIViewController) {
        print(error.localizedDescription)
        switch(error.localizedDescription) {
        case "The email address is badly formatted.":
            let invalidEmail = UIAlertController(title: "Email is not properly formatted.", message:
                "Please enter a valid email to sign up with..", preferredStyle: UIAlertControllerStyle.alert)
            invalidEmail.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(invalidEmail, animated: true, completion: nil)
            break;
        case "The email address is already in use by another account.":
            let invalidEmail = UIAlertController(title: "The email address is already in use by another account.", message:
                "Please enter a valid email to sign up with.", preferredStyle: UIAlertControllerStyle.alert)
            invalidEmail.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(invalidEmail, animated: true, completion: nil)
            break;
            
        case "The password must be 6 characters long or more.":
            let invalidPasswordLength = UIAlertController(title: "The password must be 6 characters long or more.", message:
                "Please enter a password that is at least 6 characters long.", preferredStyle: UIAlertControllerStyle.alert)
            invalidPasswordLength.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(invalidPasswordLength, animated: true, completion: nil)
            break;
        default:
            let generalErrorAlert = UIAlertController(title: "We are having trouble signing you up.", message:
                "We are having trouble signing you up, please try again soon.", preferredStyle: UIAlertControllerStyle.alert)
            generalErrorAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
            SVProgressHUD.dismiss()
            controller.present(generalErrorAlert, animated: true, completion: nil)
            break;
        }
    }
    
    private static func resetErrors(error: Error, controller: UIViewController){
        print(error.localizedDescription)
 
            switch error.localizedDescription{
            case "There is no user record corresponding to this identifier. The user may have been deleted." :
                let invalidEmail = UIAlertController(title: "There is no user record corresponding to this email", message:
                    "Please enter the email connected to your account..", preferredStyle: UIAlertControllerStyle.alert)
                invalidEmail.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                SVProgressHUD.dismiss()
                controller.present(invalidEmail, animated: true, completion: nil)
                
                break;
  
            default :
                
                let generalErrorAlert = UIAlertController(title:"Try again later", message:
                     "We are having trouble processing your password reset request.", preferredStyle: UIAlertControllerStyle.alert)
                generalErrorAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                SVProgressHUD.dismiss()
                controller.present(generalErrorAlert, animated: true, completion: nil)
                break;
            }
        
    }
    

}
