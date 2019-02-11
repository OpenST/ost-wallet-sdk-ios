//
//  EntryViewController.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {
    
    let signupSegue = "entryToSignupVC"
    let loginSegue = "entryToLoginVC"
    
    let mobileNumberLength = 10

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var userNameErrorLabel: UILabel!
    @IBOutlet weak var mobileNumberErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userNameTextField.text = "aniket\(Int(Date().timeIntervalSince1970))"
        mobileNumberTextField.text = "\(Int(Date().timeIntervalSince1970))"
    }
    
    func canProceed() -> Bool {
        var isCorrectData = true
        if (userNameTextField.text?.isEmpty)! {
            userNameErrorLabel.text = "user name is mandetory."
            isCorrectData = false
        }else {
            userNameErrorLabel.text = ""
        }
        
        if (mobileNumberTextField.text?.isEmpty)! ||
            mobileNumberLength > (mobileNumberTextField.text?.count)! {
            mobileNumberErrorLabel.text = "mobile number should be of 10 digit."
            isCorrectData = false
        }else {
            userNameErrorLabel.text = ""
        }
        return isCorrectData
    }
    
    //MARK: - Button Action
    @IBAction func signupButtonTapped(_ sender: Any) {
        if canProceed() {
            performSegue(withIdentifier: signupSegue, sender: nil)
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if canProceed() {
            performSegue(withIdentifier: loginSegue, sender: nil)
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case signupSegue:
            let signupViewController = segue.destination as! SignupViewController
            signupViewController.mobileNumber = mobileNumberTextField.text!
            signupViewController.username = userNameTextField.text!
        case loginSegue:
            let signupViewController = segue.destination as! LoginViewController
            signupViewController.mobileNumber = mobileNumberTextField.text!
            signupViewController.username = userNameTextField.text!
        default:
            return
        }
    }
    

}
