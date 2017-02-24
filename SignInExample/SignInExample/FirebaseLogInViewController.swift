//
//  FirebaseLogInViewController.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn

class FirebaseLogInViewController: UIViewController, GIDSignInDelegate {
    
    let fbReadPermission = ["public_profile", "email", "user_friends"]
    
    @IBOutlet var userNameTextField: UITextField!
    
    @IBOutlet weak var emailTextFieldForRegister: UITextField!
    
    @IBOutlet weak var passwordTextFieldForRegister: UITextField!
    
    @IBOutlet var emailTextFieldForLogIn: UITextField!
    
    @IBOutlet weak var passwordTextFieldForLogIn: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        userNameTextField.delegate = self
        emailTextFieldForRegister.delegate = self
        passwordTextFieldForRegister.delegate = self
        emailTextFieldForLogIn.delegate = self
        passwordTextFieldForLogIn.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        
        do{
            try FIRAuth.auth()?.signOut()
        }catch let logOutError {
            print(logOutError)
        }
    }
    
    @IBAction func facebookLogIn(_ sender: UIButton) {
        
        FBSDKLoginManager().logIn(withReadPermissions:fbReadPermission, from: self) { (result, error) in
            
            if error != nil{
                //登入失敗 請重新登入
                print(error!)
                return
            }else{
                
                //確定登入fb後，用戶資料再用來登入firebase
                firebaseWorks.signInFireBaseWithFB(completion: {
                    (result) in
                    
                    if result == Result.success{
                        self.performSegue(withIdentifier: "goToShowDataPage", sender: self)
                    }
                })
            }
        }
        
    }
    
    @IBAction func googleLogIn(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            print(error)
            return
        }else{
            
            firebaseWorks.signInFireBaseWithGoogle(user: user, completion: { (result) in
                
                if result == Result.success{
                    self.performSegue(withIdentifier: "goToShowDataPage", sender: self)
                    //跳轉進主頁
                }
                
            })
            
        }
    }
    
    @IBAction func registerByEmail(_ sender: UIButton) {
        
        guard let name = userNameTextField.text, let email = emailTextFieldForRegister.text, let password = passwordTextFieldForRegister.text else {
            print("Form is not valid")
            return
        }
        
        firebaseWorks.registerFirebaseByEmail(name: name, email: email, password: password)
        
    }
    
    @IBAction func logInByEmail(_ sender: UIButton) {
        
        guard let email = emailTextFieldForLogIn.text, let password = passwordTextFieldForLogIn.text else {
            print("Form is not valid")
            return
        }
        firebaseWorks.signInFirebaseWithEmail(email: email, password: password) { (result) in
            if result == Result.success{
                self.performSegue(withIdentifier: "goToShowDataPage", sender: self)
            }
        }
    }
    
    @IBAction func forgetPassWord(_ sender: UIButton) {
        

        firebaseWorks.forgetPasswordWithEmail(email: emailTextFieldForLogIn.text!)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToShowDataPage"{
            if let showAllDatasVC = segue.destination as? ShowAllDatasViewController{
                
            }
            
        }
    }
    
    func hideKeyboard() {
        userNameTextField.resignFirstResponder()
        emailTextFieldForRegister.resignFirstResponder()
        passwordTextFieldForRegister.resignFirstResponder()
        emailTextFieldForLogIn.resignFirstResponder()
        passwordTextFieldForLogIn.resignFirstResponder()
    }
}

extension FirebaseLogInViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
