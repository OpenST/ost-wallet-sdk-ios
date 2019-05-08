//
//  IntroViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class IntroViewController: OstBaseScrollViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK - Subviews
    let logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "ostLogoBlue") );
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    
    let leadLabel: UILabel = {
        let view = OstUIKit.leadLabel();
        view.text = "Test your Brand Token Economy deployed on OST Platform";
        view.backgroundColor = .white;
        return view;
    }()
    
    let introImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "ostIntroImage") );
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let createAccountBtn: UIButton = {
        let view = OstUIKit.primaryButton();
        view.setTitle("Create Account", for: .normal);
        return view;
    }()

    let loginBtn: UIButton = {
        let view = OstUIKit.secondaryButton();
        view.setTitle("Log in", for: .normal);
        return view;
    }()
    
    override func addSubviews() {
        super.addSubviews();
        addSubview(logoImageView);
        addSubview(leadLabel);
        addSubview(introImageView);
        addSubview(createAccountBtn);
        addSubview(loginBtn);
    }

    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        
        logoImageView.topAlignWithParent(constant: 30);
        logoImageView.centerXAlignWithParent();
        logoImageView.setAspectRatio(width: 70, height: 38);
        
        leadLabel.placeBelow(toItem: logoImageView);
        leadLabel.applyBlockElementConstraints();
        
        introImageView.placeBelow(toItem: leadLabel, constant: 40);
        introImageView.setAspectRatio(width: 221, height: 236);
        introImageView.centerXAlignWithParent();
        
        createAccountBtn.placeBelow(toItem: introImageView, constant: 60);
        createAccountBtn.applyBlockElementConstraints();
        
        loginBtn.placeBelow(toItem: createAccountBtn);
        loginBtn.applyBlockElementConstraints();
        
        
        //Update lastView as needed.
        let lastView = loginBtn;
        lastView.bottomAlignWithParent(constant: -20);
    }

}
