//
//  DeviceMnemonicsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class DeviceMnemonicsViewController: BaseSettingOptionsViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var titleLabel: UILabel?
    var collectionView: UICollectionView?
    
    override func createViews() {
        super.createViews()
        createLabel()
        createCollectionView()
    }
    
    func createLabel() {
        let label = UILabel()
        label.text = "Write down your 12-word mnemonic phrase and store them securely"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()

        titleLabel = label
        contentView.addSubview(titleLabel!)
    }
    
    func createCollectionView() {
        let collectioViewFlowLayout = UICollectionViewFlowLayout()
        collectioViewFlowLayout.minimumLineSpacing = 0.0
        let loCollectionView = UICollectionView(frame: .zero, collectionViewLayout: collectioViewFlowLayout)
        loCollectionView.delegate = self
        loCollectionView.dataSource = self
        loCollectionView.backgroundColor = .gray
        loCollectionView.clipsToBounds = true
        loCollectionView.layer.cornerRadius = 7
        loCollectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        loCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.collectionView = loCollectionView
        contentView.addSubview(loCollectionView)
        
        registerCollectionViewCell()
    }
    
    func registerCollectionViewCell() {
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "abc")
    }
    
    override func applyConstraints() {
        super.applyConstraints()
        applyTitleLabelConstraints()
        applyCollectionViewConstraints()
        
        applyContentViewBottomAnchor(with: self.collectionView!)
    }
    
    func applyTitleLabelConstraints() {
        guard let parent = titleLabel?.superview else {return}
        titleLabel?.topAnchor.constraint(equalTo: parent.topAnchor, constant: 26).isActive = true
        titleLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        titleLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
    }
    
    func applyCollectionViewConstraints() {
        guard let parent = collectionView?.superview else {return}
        
        collectionView?.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: 26).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 26).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -26).isActive = true
        collectionView?.heightAnchor.constraint(equalToConstant: 44*6).isActive = true
    }
    
    //MARK: - Collection View
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "abc", for: indexPath)
        cell.backgroundColor = .white
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width/2), height: 44)
    }
}
