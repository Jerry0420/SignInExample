//
//  UploadDatasViewController.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class UploadDatasViewController: UIViewController {
    
    @IBOutlet weak var uploadImageView: UIImageView!
    
    @IBOutlet weak var uploadTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uploadTextField.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))

        // Do any additional setup after loading the view.
    }

    @IBAction func backToShowDataPage(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadSuccess(_ sender: UIBarButtonItem) {
        
        guard let text = self.uploadTextField.text, let image = uploadImageView.image else{
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        firebaseWorks.uploadImageToStorage(image: image, childName: "Upload Image") { (imageURL) in
            
            let properties = ["Text": text as AnyObject,"Image URL":imageURL as AnyObject] as [String: AnyObject]
            
            firebaseWorks.uploadTextToDataBase(properties: properties, childName: "Upload Data", completion: { (result) in
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                if result == Result.success{
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
        }
    }
    
    func hideKeyboard() {
        uploadTextField.resignFirstResponder()
    }

}

extension UploadDatasViewController: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        hideKeyboard()
        return true
    }
}
