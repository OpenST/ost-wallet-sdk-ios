//
//  BaseSettingOptionsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class BaseSettingOptionsViewController: UIViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    let contentView = UIView()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        createViews()
    }
    
    func createViews() {
        setupScrollView()
    }
    
    func setupScrollView(){
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyConstraints()
    }
    
    func applyContentViewBottomAnchor(with view: UIView) {
        guard let parent = view.superview else {return}
        view.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func applyConstraints() {
     
    }
}
