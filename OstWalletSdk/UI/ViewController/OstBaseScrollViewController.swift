//
//  BaseScrollViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseScrollViewController: OstBaseViewController {
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        scrollView.backgroundColor = .white;
        scrollView.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        scrollView.isDirectionalLockEnabled = true;
        return scrollView
    }()
    
    let svContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.backgroundColor = .white;
        return view;
    }()
    
    //Helper method to add subview to scroll view.
    override func addSubview( _ view: UIView ) {
        svContentView.addSubview( view );
    }
    
    func addSubviewToViewControllerView( _ view: UIView ) {
        super.addSubview( view );
    }

    override func addSubviews() {
        super.addSubviews();
        super.addSubview( scrollView );
        scrollView.addSubview( svContentView );
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        addScrollViewLayoutConstraints();
    }
    
    func addScrollViewLayoutConstraints() {
        scrollView.applyBlockElementConstraints(horizontalMargin: 0);
        scrollView.topAlignWithParent();
        scrollView.bottomAlignWithParent();
        
        svContentView.applyBlockElementConstraints(horizontalMargin: 0);
        svContentView.topAlignWithParent();
        svContentView.bottomAlignWithParent(constant: -20.0);

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        scrollView.contentSize.width = self.view.frame.width;
    }
    
    @available(iOS 11.0, *)
    func alignTopWithScrollView(view:UIView, constant:CGFloat = 20) {
        scrollView.addConstraint(NSLayoutConstraint(item: view,
                                                    attribute: .top,
                                                    relatedBy: .equal,
                                                    toItem: scrollView.contentLayoutGuide,
                                                    attribute: .topMargin,
                                                    multiplier: 1.0,
                                                    constant: constant));
    }
    
    @available(iOS 11.0, *)
    func alignBottomWithScrollView(view:UIView, constant:CGFloat = -20) {
        scrollView.addConstraint(NSLayoutConstraint(item: view,
                                                    attribute: .bottom,
                                                    relatedBy: .equal,
                                                    toItem: scrollView.contentLayoutGuide,
                                                    attribute: .bottomMargin,
                                                    multiplier: 1.0,
                                                    constant: constant));
    }
    
    func applyBlockElementConstraints(view:UIView, constant:CGFloat = 0) {
        scrollView.addConstraint(NSLayoutConstraint(item: view,
                                                    attribute: .leading,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .leading,
                                                    multiplier: 1.0,
                                                    constant: constant));
        
        scrollView.addConstraint(NSLayoutConstraint(item: view,
                                                    attribute: .trailing,
                                                    relatedBy: .equal,
                                                    toItem: scrollView,
                                                    attribute: .trailing,
                                                    multiplier: 1.0,
                                                    constant: constant));
    }
}
