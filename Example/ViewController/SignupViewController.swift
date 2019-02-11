//
//  SignupViewController.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk

class SignupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userDetailsTableView: UITableView!

    let userDetailsReuseIdentifier = "userDetailsReuseIdentifier"
    
    var username: String = ""
    var mobileNumber: String = ""
    var mappyUser: [String: Any]? = nil
    
    var userDetailsTabelArray: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableViewCells()
        createUser()
    }
    
    func registerTableViewCells() {
//        let userCell = UINib(nibName: "UserDetailsTableViewCell", bundle: nil)
//        userDetailsTableView.register(userCell, forCellReuseIdentifier: userDetailsReuseIdentifier)
        //userDetailsTableView.register(UserDetailsTableViewCell.self, forCellReuseIdentifier: userDetailsReuseIdentifier)
    }
    
    func userParam() -> [String: Any]{
        return ["username": username, "mobile_number": mobileNumber]
    }
    
    func createUser() {
        MappyUser().createUser(params: userParam(), success: { (userObj) in
            self.mappyUser = userObj
            SharedDatabase.sharedInstance.insertUser(userObj)
            self.userDetailsTabelArray.append(userObj)
            self.relaodTable()
            self.createOstUser(for: (userObj["_id"] as! String))
        }) { (failaurObj) in
            print(failaurObj as Any)
        }
    }
    
    func createOstUser(for userId: String) {
        MappyUser().createOstUser(for: userId, success: { (ostUserObj) in
           self.parseUser(ostUserObj)
        }) { (failuarObj) in
            print(failuarObj as Any)
        }
    }
    
    func parseUser(_ ostUserObj: [String: Any]) {
        do {
            var ostUserObj = ostUserObj
            ostUserObj["id"] = ostUserObj["user_id"]
            if let user: OstUser = try OstSdk.parseUser(ostUserObj) {
                try RegisterDevice(userId: user.id, tokenId: user.token_id!, mappyUserId: (mappyUser!["_id"] as! String)).perform()
            }
            
        }catch let error{
            Logger.log(message: "parseUser", parameterToPrint: error)
        }
    }
    
    func relaodTable(withData tableDataArray: [[String: Any]]? = nil) {
        if tableDataArray != nil {
            userDetailsTabelArray = tableDataArray!
        }
        userDetailsTableView.reloadData()
    }
    
}

extension SignupViewController {
    //MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailsTabelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UserDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: userDetailsReuseIdentifier, for: indexPath) as! UserDetailsTableViewCell
        
        let userDetails = userDetailsTabelArray[indexPath.row]
        cell.setUserDetails(userDetails)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
