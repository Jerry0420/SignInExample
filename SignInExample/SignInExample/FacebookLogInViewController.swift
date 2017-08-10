//
//  FacebookLogInViewController.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/21.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookLogInViewController: UIViewController, FBSDKLoginButtonDelegate {

    
    @IBOutlet weak var facebookLogInButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        facebookLogInButton.readPermissions = ["public_profile", "email", "user_friends"]
        facebookLogInButton.delegate = self
        
        //        第一次登入後可取得使用者token，後續即可直接登入
        if (FBSDKAccessToken.current()) != nil{
            fetchProfile()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FBSDKLoginManager().logOut()
    }
    
    func fetchProfile(){
        print("attempt to fetch profile......")
        
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start(completionHandler: {
            connection, result, error -> Void in
            
            
            if error != nil {
                print("登入失敗")
                print("longinerror =\(error)")
                return
            } else {
                
                if let resultNew = result as? [String:Any]{
                    
                    print("成功登入")
                    
                    let email = resultNew["email"]  as! String
                    print(email)
                    
                    let firstName = resultNew["first_name"] as! String
                    print(firstName)
                    
                    let lastName = resultNew["last_name"] as! String
                    print(lastName)
                    
                    if let picture = resultNew["picture"] as? NSDictionary,
                        let data = picture["data"] as? NSDictionary,
                        let url = data["url"] as? String {
                        print(url) //臉書大頭貼的url, 再放入imageView內秀出來
                    }
                }
                
                
            }
        })
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        fetchProfile()
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    @IBAction func facebookCustomLogIn(_ sender: UIButton) {
        
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, error) in
            
            if error != nil{
                
                print("longinerror =\(error)")
                
                return
            }
            
            self.fetchProfile()
            
        }
        
    }
    
    @IBAction func facebookLogOut(_ sender: UIButton) {
        
        FBSDKLoginManager().logOut()
    }
    

}
