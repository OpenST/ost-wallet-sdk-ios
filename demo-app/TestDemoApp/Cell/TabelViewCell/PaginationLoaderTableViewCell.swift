//
//  DAPaginationLoaderTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 22/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class PaginationLoaderTableViewCell: BaseTableViewCell {

    static var cellIdentifier: String {
        return String(describing: PaginationLoaderTableViewCell.self)
    }
    
    var activityContainer: UIView?
    var activityIndicator: UIActivityIndicatorView?
    
    //MARK: - Views
    override func createViews() {
        createIndicatorContainer()
        createActivityIndicatorView()
        
        self.selectionStyle = .none
    }
    
    func createIndicatorContainer() {
        let container = UIView()
        container.backgroundColor = .white
        self.activityContainer = container
        self.addSubview(container)
    }
    func createActivityIndicatorView() {
        let aIndicator = UIActivityIndicatorView()
        aIndicator.color = UIColor.color(22, 141, 193)
        
        self.activityIndicator = aIndicator
        self.activityContainer?.addSubview(aIndicator)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        applyActivityContainerConstraints()
        applyActivityIndicatorConstraints()
    }
    
    func applyActivityContainerConstraints() {
        guard let parent = self.activityContainer?.superview else {return}
        self.activityContainer?.translatesAutoresizingMaskIntoConstraints = false
        self.activityContainer?.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        self.activityContainer?.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        self.activityContainer?.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.activityContainer?.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func applyActivityIndicatorConstraints() {
        guard let parent = self.activityIndicator?.superview else {return}
        self.activityIndicator?.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicator?.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        self.activityIndicator?.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    
    //MARK: - Methods

    func startAnimating() {
        self.activityIndicator?.startAnimating()
    }
    
    func stopAnimating() {
        self.activityIndicator?.stopAnimating()
    }
}
