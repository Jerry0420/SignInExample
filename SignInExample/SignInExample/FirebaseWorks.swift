//
//  FirebaseWorks.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit
import GoogleSignIn

let firebaseWorks = FirebaseWorks()

enum Result{
    case success
    case fail
}

class FirebaseWorks{
    
    func signInFireBaseWithFB(completion: @escaping (_ result: Result) -> ()){
        
        let fbAccessToken = FBSDKAccessToken.current()
        guard let fbAccessTokenString = fbAccessToken?.tokenString else { return }
        
        let fbCredentials = FIRFacebookAuthProvider.credential(withAccessToken: fbAccessTokenString)
        firebaseSignInWithCredential(credential: fbCredentials, completion: completion)
    }
    
    func signInFireBaseWithGoogle(user: GIDGoogleUser,completion: @escaping (_ result: Result) -> ()){
        
        guard let authentication = user.authentication else { return }
        let googleCredential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        firebaseSignInWithCredential(credential: googleCredential, completion: completion)
        
    }
    
    func firebaseSignInWithCredential(credential: FIRAuthCredential,completion: @escaping (_ result: Result) -> ()){
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                //登入失敗 請重新登入
                print("Something went wrong with our FB user: ", error ?? "")
                return
            }else{
                
                print("Successfully logged in with our user: ", user ?? "")
                
                guard let uid = user?.uid else {
                    return
                }
                
                guard let profileImageUrl = user?.photoURL?.absoluteString, let email = user?.email, let name = user?.displayName else{
                    return
                }
                //可自行選擇想要上傳的使用者資料
                let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": profileImageUrl as AnyObject] as [String: AnyObject]
                
                let ref = FIRDatabase.database().reference()
                
                let usersReference = ref.child("users").child(uid)
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    if err != nil{
                        print(err!)
                        return
                    }
                    
                    completion(Result.success)
                    
                })
                
            }
        })
    }
    
    func registerFirebaseByEmail(name: String, email: String, password: String){
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil{
                print(error?.localizedDescription as Any)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let values = ["name": name as AnyObject, "email": email as AnyObject, "profileImageUrl": "" as AnyObject] as [String: AnyObject]
            
            let ref = FIRDatabase.database().reference()
            
            let usersReference = ref.child("users").child(uid)
            
            usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                
                user?.sendEmailVerification() { error in
                    if let error = error {
                        print(error)
                    } else {
                        //
                        
                    }
                }
                
            })
            
        })
    }
    
    func signInFirebaseWithEmail(email: String, password: String, completion: @escaping (_ result: Result) -> ()){
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil {
                
                print(error?.localizedDescription as Any)
                return
            }else{
                completion(Result.success)
            }
            
        })
    }
    
    func forgetPasswordWithEmail(email: String){
        FIRAuth.auth()?.sendPasswordReset(withEmail: email) { error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                // 寄送新密碼
            }
        }
    }
    
    func uploadImageToStorage(image: UIImage, childName: String, completion: @escaping (_ result: String) -> ()){
        
        let imageName = NSUUID().uuidString
        
        let ref = FIRStorage.storage().reference().child(childName).child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 1) {
            
            ref.put(uploadData, metadata: nil, completion: { (metadata, error) in
                
                if error != nil {
                    print("Failed to upload image:", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    completion(imageUrl)
                }
            })
        }
    }
    
    func uploadTextToDataBase(properties: [String: AnyObject],childName: String, completion: @escaping (_ result: Result) -> ()){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child(childName).child(uid)
        
        let childRef = ref.childByAutoId() //隨機建立的id
        
        var properties = properties
        
        properties["Child ID"] = childRef.key as AnyObject
        
        childRef.updateChildValues(properties, withCompletionBlock: {
            (error, ref) in
            
            if error != nil{
                print(error!)
                return
            }else{
                
                completion(Result.success)
            }
            
        })
    }
    
    func removeDataFromFirebaseDataBase(childID: String,childName: String, completion: @escaping (_ result: Result) -> ()){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        FIRDatabase.database().reference().child(childName).child(uid).child(childID).removeValue(completionBlock: { (error, ref) in
            
            if error != nil{
                print(error!)
                return
            }else{
                
                completion(Result.success)
            }
        })
    }
    
    func fetchDataFromFirebaseDataBase(childName: String, completion: @escaping (_ data: [String: AnyObject], _ childID: String) -> ()){
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let reference = FIRDatabase.database().reference().child(childName).child(uid)
        reference.observe(.childAdded, with: {
            (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                completion(dictionary, snapshot.key)
                
            }
            
        }, withCancel: nil)
    }
    
}
