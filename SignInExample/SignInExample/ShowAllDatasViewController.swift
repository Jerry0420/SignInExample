//
//  ShowAllDatasViewController.swift
//  SignInExample
//
//  Created by JerryWang on 2017/2/22.
//  Copyright © 2017年 Jerrywang. All rights reserved.
//

import UIKit
import Firebase

class ShowAllDatasViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var datas = [AnyObject]()
    var datasImage = [UIImage]()
    
    var datasDictionaries = [String:AnyObject](){
        didSet{
            processFetchedData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.main.async {
            
            firebaseWorks.fetchDataFromFirebaseDataBase(childName: "Upload Data") { (dictionary, childID) in
                self.datasDictionaries[childID] = dictionary as AnyObject?
            }
        }
        
    }
    
    func processFetchedData() {
        
        self.datas = Array(self.datasDictionaries.values)
        
        DispatchQueue.main.async(execute: {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.tableView.reloadData()
            
        })
    }
    
    @IBAction func backToLogInPage(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension ShowAllDatasViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasDictionaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if let text = datas[indexPath.row]["Text"] as? String{
            cell.textLabel?.text = text
        }
        
        if let imageURLString = datas[indexPath.row]["Image URL"] as? String{
            let imageURL = URL(string: imageURLString)!
            if let imageData = try? Data(contentsOf: imageURL){
                cell.imageView?.image = UIImage(data: imageData)
            }
        }
        
        return cell

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "刪除", handler: {
            (action:UITableViewRowAction! , indexPath:IndexPath!) -> Void in
            
            let data = self.datas[indexPath.row]
            
            guard let childID = data["Child ID"] as? String else{
                return
            }
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            
            firebaseWorks.removeDataFromFirebaseDataBase(childID: childID, childName: "Upload Data", completion: { (result) in
                
                if result == Result.success{
                    self.datasDictionaries.removeValue(forKey: childID)
                }
            })
        })
        return [deleteAction]
    }
}

