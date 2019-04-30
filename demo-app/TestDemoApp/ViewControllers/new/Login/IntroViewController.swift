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
        let view = UILabel();
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.text = "Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller Pass the selected object to the new view controller";
        view.backgroundColor = .white;
        view.numberOfLines = 0;
        return view;
    }()
    
    override func addSubviews() {
        super.addSubviews();
        addSubview(logoImageView);
        addSubview(leadLabel);
    }

    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        logoImageView.topAlignWithParent();
        logoImageView.centerAlignWithParent();
        logoImageView.setAspectRatio(width: 70, height: 38);
        
        leadLabel.placeBelow(toItem: logoImageView);
        leadLabel.applyBlockElementConstraints();
        leadLabel.bottomAlignWithParent();
    }

}
