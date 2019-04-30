//
//  BaseSettingOptionsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import Foundation
import OstWalletSdk

class BaseSettingOptionsViewController: UIViewController, FlowCompleteDelegate, FlowInterruptedDelegate, RequestAcknowledgedDelegate {
    
    //MARK: - Components
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    let contentView = UIView()
    
    //MAKR: - Themer
    var navigationThemer: OstNavigation =  OstTheme.blueNavigation
    
    //MAKR: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        createViews()
    }
    
    
    //MARK: - Create Views
    func createViews() {
        setupNavigationBar()
        setupScrollView()
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = getNavBarTitle()
        if nil != self.navigationController {
            weak var weakSelf = self
            navigationThemer.apply(self.navigationController!, target: weakSelf, action: #selector(weakSelf!.tappedBackButton))
        }
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
    
    //MAKR: - Apply Constraints
    func applyContentViewBottomAnchor(with view: UIView) {
        guard let parent = view.superview else {return}
        view.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func applyConstraints() {
     
    }
    
    func getNavBarTitle() -> String {
        return ""
    }
    
    //MARK: - Sdk Interact Delegate
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
    
    //MAKR: - Actions
    @objc func tappedBackButton() {
        
        // Do your thing
        self.dismiss(animated: true, completion: nil)
    }
}


class CustomBackButton: NSObject {
    
    class func createWithImage(image: UIImage, color: UIColor, target: AnyObject?, action: Selector) -> [UIBarButtonItem] {
        // recommended maximum image height 22 points (i.e. 22 @1x, 44 @2x, 66 @3x)
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -8
        
        let backImageView = UIImageView(image: image)
        let customBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backImageView.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        customBarButton.addSubview(backImageView)
        customBarButton.addTarget(target, action: action, for: .touchUpInside)
        
        return [negativeSpacer, UIBarButtonItem(customView: customBarButton)]
    }
}
